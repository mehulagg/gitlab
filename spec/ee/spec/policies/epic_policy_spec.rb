require 'spec_helper'

describe EpicPolicy do
  let(:user) { create(:user) }

  def permissions(user, group)
    epic = create(:epic, group: group)

    described_class.new(user, epic)
  end

  context 'when epics feature is disabled' do
    let(:group) { create(:group, :public) }

    it 'no one can read epics' do
      group.add_owner(user)

      expect(permissions(user, group))
        .to be_disallowed(:read_epic, :update_epic, :destroy_epic, :admin_epic, :create_epic)
    end
  end

  context 'when epics feature is enabled' do
    before do
      stub_licensed_features(epics: true)
    end

    context 'when an epic is in a private group' do
      let(:group) { create(:group, :private) }

<<<<<<< HEAD
      expect(permissions(user, group))
        .to be_allowed(:read_epic, :update_epic, :destroy_epic, :admin_epic, :create_epic)
    end
  end
=======
      it 'anonymous user can not read epics' do
        expect(permissions(nil, group))
          .to be_disallowed(:read_epic, :update_epic, :destroy_epic, :admin_epic, :create_epic)
      end

      it 'user who is not a group member can not read epics' do
        expect(permissions(user, group))
          .to be_disallowed(:read_epic, :update_epic, :destroy_epic, :admin_epic, :create_epic)
      end

      it 'guest group member can only read epics' do
        group.add_guest(user)
>>>>>>> 74d5422a10... Merge branch '3731-eeu-license' into 'master'

        expect(permissions(user, group)).to be_allowed(:read_epic)
        expect(permissions(user, group)).to be_disallowed(:update_epic, :destroy_epic, :admin_epic, :create_epic)
      end

      it 'reporter group member can manage epics' do
        group.add_reporter(user)

        expect(permissions(user, group)).to be_disallowed(:destroy_epic)
        expect(permissions(user, group))
          .to be_allowed(:read_epic, :update_epic, :admin_epic, :create_epic)
      end

      it 'only group owner can destroy epics' do
        group.add_owner(user)

        expect(permissions(user, group))
          .to be_allowed(:read_epic, :update_epic, :destroy_epic, :admin_epic, :create_epic)
      end
    end

    context 'when an epic is in an internal group' do
      let(:group) { create(:group, :internal) }

<<<<<<< HEAD
      expect(permissions(user, group))
        .to be_allowed(:read_epic, :update_epic, :destroy_epic, :admin_epic, :create_epic)
    end
  end
=======
      it 'anonymous user can not read epics' do
        expect(permissions(nil, group))
          .to be_disallowed(:read_epic, :update_epic, :destroy_epic, :admin_epic, :create_epic)
      end

      it 'user who is not a group member can only read epics' do
        expect(permissions(user, group)).to be_allowed(:read_epic)
        expect(permissions(user, group)).to be_disallowed(:update_epic, :destroy_epic, :admin_epic, :create_epic)
      end

      it 'guest group member can only read epics' do
        group.add_guest(user)
>>>>>>> 74d5422a10... Merge branch '3731-eeu-license' into 'master'

        expect(permissions(user, group)).to be_allowed(:read_epic)
        expect(permissions(user, group)).to be_disallowed(:update_epic, :destroy_epic, :admin_epic, :create_epic)
      end

      it 'reporter group member can manage epics' do
        group.add_reporter(user)

        expect(permissions(user, group)).to be_disallowed(:destroy_epic)
        expect(permissions(user, group))
          .to be_allowed(:read_epic, :update_epic, :admin_epic, :create_epic)
      end

      it 'only group owner can destroy epics' do
        group.add_owner(user)

        expect(permissions(user, group))
          .to be_allowed(:read_epic, :update_epic, :destroy_epic, :admin_epic, :create_epic)
      end
    end

    context 'when an epic is in a public group' do
      let(:group) { create(:group, :public) }

<<<<<<< HEAD
      expect(permissions(user, group))
        .to be_allowed(:read_epic, :update_epic, :destroy_epic, :admin_epic, :create_epic)
=======
      it 'anonymous user can only read epics' do
        expect(permissions(nil, group)).to be_allowed(:read_epic)
        expect(permissions(nil, group)).to be_disallowed(:update_epic, :destroy_epic, :admin_epic, :create_epic)
      end

      it 'user who is not a group member can only read epics' do
        expect(permissions(user, group)).to be_allowed(:read_epic)
        expect(permissions(user, group)).to be_disallowed(:update_epic, :destroy_epic, :admin_epic, :create_epic)
      end

      it 'guest group member can only read epics' do
        group.add_guest(user)

        expect(permissions(user, group)).to be_allowed(:read_epic)
        expect(permissions(user, group)).to be_disallowed(:update_epic, :destroy_epic, :admin_epic, :create_epic)
      end

      it 'reporter group member can manage epics' do
        group.add_reporter(user)

        expect(permissions(user, group)).to be_disallowed(:destroy_epic)
        expect(permissions(user, group))
          .to be_allowed(:read_epic, :update_epic, :admin_epic, :create_epic)
      end

      it 'only group owner can destroy epics' do
        group.add_owner(user)

        expect(permissions(user, group))
          .to be_allowed(:read_epic, :update_epic, :destroy_epic, :admin_epic, :create_epic)
      end
>>>>>>> 74d5422a10... Merge branch '3731-eeu-license' into 'master'
    end
  end
end
