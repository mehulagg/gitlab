require 'spec_helper'

describe Gitlab::Graphql::Connections::KeysetConnection do
  let(:nodes) { Project.all.order(id: :asc) }
  let(:arguments) { {} }
  subject(:connection) do
    described_class.new(nodes, arguments, max_page_size: 3)
  end

  def encoded_cursor(node)
    described_class.new(nodes, {}).cursor_from_node(node)
  end

  def decoded_cursor(cursor)
    JSON.parse(Base64Bp.urlsafe_decode64(cursor))
  end

  describe '#cursor_from_nodes' do
    let(:project) { create(:project) }
    let(:cursor)  { connection.cursor_from_node(project) }

    it 'returns an encoded ID' do
      expect(decoded_cursor(cursor)).to eq({ 'id' => project.id.to_s })
    end

    context 'when an order was specified' do
      let(:nodes) { Project.order(:updated_at) }

      it 'returns the encoded value of the order' do
        expect(decoded_cursor(cursor)).to eq({ 'updated_at' => project.updated_at.to_s })
      end
    end

    context 'when multiple orders is specified' do
      let(:nodes) { Project.order(:updated_at).order(:id) }

      it 'returns the encoded value of the order' do
        expect(decoded_cursor(cursor)).to eq({ 'updated_at' => project.updated_at.to_s, 'id' => project.id.to_s })
      end
    end

    context 'when multiple orders with SQL is specified' do
      let(:nodes) { Project.order(Arel.sql('projects.updated_at IS NULL')).order(:updated_at).order(:id) }

      it 'returns the encoded value of the order' do
        expect(decoded_cursor(cursor)).to eq({ 'updated_at' => project.updated_at.to_s, 'id' => project.id.to_s })
      end
    end
  end

  describe '#sliced_nodes' do
    let(:projects) { create_list(:project, 4) }

    context 'when before is passed' do
      let(:arguments) { { before: encoded_cursor(projects[1]) } }

      it 'only returns the project before the selected one' do
        expect(subject.sliced_nodes).to contain_exactly(projects.first)
      end

      context 'when the sort order is descending' do
        let(:nodes) { Project.all.order(id: :desc) }

        it 'returns the correct nodes' do
          expect(subject.sliced_nodes).to contain_exactly(*projects[2..-1])
        end
      end
    end

    context 'when after is passed' do
      let(:arguments) { { after: encoded_cursor(projects[1]) } }

      it 'only returns the project before the selected one' do
        expect(subject.sliced_nodes).to contain_exactly(*projects[2..-1])
      end

      context 'when the sort order is descending' do
        let(:nodes) { Project.all.order(id: :desc) }

        it 'returns the correct nodes' do
          expect(subject.sliced_nodes).to contain_exactly(projects.first)
        end
      end
    end

    context 'when both before and after are passed' do
      let(:arguments) do
        {
          after: encoded_cursor(projects[1]),
          before: encoded_cursor(projects[3])
        }
      end

      it 'returns the expected set' do
        expect(subject.sliced_nodes).to contain_exactly(projects[2])
      end
    end

    context 'when multiple orders are defined' do
      let!(:project1) { create(:project, last_repository_check_at: 10.days.ago) }    # Asc: project5  Desc: project3
      let!(:project2) { create(:project, last_repository_check_at: nil) }            # Asc: project1  Desc: project1
      let!(:project3) { create(:project, last_repository_check_at: 5.days.ago) }     # Asc: project3  Desc: project5
      let!(:project4) { create(:project, last_repository_check_at: nil) }            # Asc: project2  Desc: project2
      let!(:project5) { create(:project, last_repository_check_at: 20.days.ago) }    # Asc: project4  Desc: project4

      context 'when ascending' do
        let(:nodes) do
          Project.order(Arel.sql('projects.last_repository_check_at IS NULL')).order(last_repository_check_at: :asc).order(id: :asc)
        end

        context 'when no cursor is passed' do
          let(:arguments) { {} }

          it 'returns projects in ascending order' do
            expect(subject.sliced_nodes).to eq([project5, project1, project3, project2, project4])
          end
        end

        context 'when before cursor value is NULL' do
          let(:arguments) { { before: encoded_cursor(project4) } }

          it 'returns all projects before the cursor' do
            expect(subject.sliced_nodes).to eq([project5, project1, project3, project2])
          end
        end

        context 'when before cursor value is not NULL' do
          let(:arguments) { { before: encoded_cursor(project3) } }

          it 'returns all projects before the cursor' do
            expect(subject.sliced_nodes).to eq([project5, project1])
          end
        end

        context 'when after cursor value is NULL' do
          let(:arguments) { { after: encoded_cursor(project2) } }

          it 'returns all projects after the cursor' do
            expect(subject.sliced_nodes).to eq([project4])
          end
        end

        context 'when after cursor value is not NULL' do
          let(:arguments) { { after: encoded_cursor(project1) } }

          it 'returns all projects after the cursor' do
            expect(subject.sliced_nodes).to eq([project3, project2, project4])
          end
        end

        context 'when before and after cursor' do
          let(:arguments) { { before: encoded_cursor(project4), after: encoded_cursor(project5) } }

          it 'returns all projects after the cursor' do
            expect(subject.sliced_nodes).to eq([project1, project3, project2])
          end
        end
      end

      context 'when descending' do
        let(:nodes) do
          Project.order(Arel.sql('projects.last_repository_check_at IS NULL')).order(last_repository_check_at: :desc).order(id: :asc)
        end

        context 'when no cursor is passed' do
          let(:arguments) { {} }

          it 'only returns projects in descending order' do
            expect(subject.sliced_nodes).to eq([project3, project1, project5, project2, project4])
          end
        end

        context 'when before cursor value is NULL' do
          let(:arguments) { { before: encoded_cursor(project4) } }

          it 'returns all projects before the cursor' do
            expect(subject.sliced_nodes).to eq([project3, project1, project5, project2])
          end
        end

        context 'when before cursor value is not NULL' do
          let(:arguments) { { before: encoded_cursor(project5) } }

          it 'returns all projects before the cursor' do
            expect(subject.sliced_nodes).to eq([project3, project1])
          end
        end

        context 'when after cursor value is NULL' do
          let(:arguments) { { after: encoded_cursor(project2) } }

          it 'returns all projects after the cursor' do
            expect(subject.sliced_nodes).to eq([project4])
          end
        end

        context 'when after cursor value is not NULL' do
          let(:arguments) { { after: encoded_cursor(project1) } }

          it 'returns all projects after the cursor' do
            expect(subject.sliced_nodes).to eq([project5, project2, project4])
          end
        end

        context 'when before and after cursor' do
          let(:arguments) { { before: encoded_cursor(project4), after: encoded_cursor(project3) } }

          it 'returns all projects after the cursor' do
            expect(subject.sliced_nodes).to eq([project1, project5, project2])
          end
        end
      end
    end

    # TODO Enable this as part of below issue
    # https://gitlab.com/gitlab-org/gitlab/issues/32933
    # context 'when an invalid cursor is provided' do
    #   let(:arguments) { { before: 'invalidcursor' } }
    #
    #   it 'raises an error' do
    #     expect { expect(subject.sliced_nodes) }.to raise_error(Gitlab::Graphql::Errors::ArgumentError)
    #   end
    # end

    # TODO Remove this as part of below issue
    # https://gitlab.com/gitlab-org/gitlab/issues/32933
    context 'when an old style cursor is provided' do
      let(:arguments) { { before: Base64Bp.urlsafe_encode64(projects[1].id.to_s, padding: false) } }

      it 'only returns the project before the selected one' do
        expect(subject.sliced_nodes).to contain_exactly(projects.first)
      end
    end
  end

  describe '#paged_nodes' do
    let!(:projects) { create_list(:project, 5) }

    it 'returns the collection limited to max page size' do
      expect(subject.paged_nodes.size).to eq(3)
    end

    it 'is a loaded memoized array' do
      expect(subject.paged_nodes).to be_an(Array)
      expect(subject.paged_nodes.object_id).to eq(subject.paged_nodes.object_id)
    end

    context 'when `first` is passed' do
      let(:arguments) { { first: 2 } }

      it 'returns only the first elements' do
        expect(subject.paged_nodes).to contain_exactly(projects.first, projects.second)
      end
    end

    context 'when `last` is passed' do
      let(:arguments) { { last: 2 } }

      it 'returns only the last elements' do
        expect(subject.paged_nodes).to contain_exactly(projects[3], projects[4])
      end
    end

    context 'when both are passed' do
      let(:arguments) { { first: 2, last: 2 } }

      it 'raises an error' do
        expect { subject.paged_nodes }.to raise_error(Gitlab::Graphql::Errors::ArgumentError)
      end
    end
  end
end
