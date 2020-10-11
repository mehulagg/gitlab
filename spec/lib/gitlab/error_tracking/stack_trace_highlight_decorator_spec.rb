# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::ErrorTracking::StackTraceHighlightDecorator do
  let(:error_event) { build(:error_tracking_error_event) }

  describe '.decorate' do
    subject(:decorate) { described_class.decorate(error_event) }

    it 'does not change issue_id' do
      expect(decorate.issue_id).to eq(error_event.issue_id)
    end

    it 'does not change date_received' do
      expect(decorate.date_received).to eq(error_event.date_received)
    end

    it 'decorates the stack trace context' do
      expect(decorate.stack_trace_entries).to eq(
        [
          {
            'function' => 'puts',
            'lineNo' => 14,
            'filename' => 'hello_world.rb',
            'context' => [
              [10, '<div id="LC1" class="line" lang="ruby"><span class="c1"># Ruby example</span></div>'],
              [11, '<div id="LC1" class="line" lang="ruby"><span class="k">class</span> <span class="nc">HelloWorld</span></div>'],
              [12, '<div id="LC1" class="line" lang="ruby">  <span class="k">def</span> <span class="nc">self</span><span class="o">.</span><span class="nf">message</span></div>'],
              [13, '<div id="LC1" class="line" lang="ruby">    <span class="vi">@name</span> <span class="o">=</span> <span class="s1">\'World\'</span></div>'],
              [14, %Q[<div id="LC1" class="line" lang="ruby">    <span class="nb">puts</span> <span class="s2">"Hello </span><span class="si">\#{</span><span class="vi">@name</span><span class="si">}</span><span class="s2">"</span></div>]],
              [15, '<div id="LC1" class="line" lang="ruby">  <span class="k">end</span></div>'],
              [16, '<div id="LC1" class="line" lang="ruby"><span class="k">end</span></div>']
            ]
          },
          {
            'function' => 'print',
            'lineNo' => 6,
            'filename' => 'HelloWorld.swift',
            'context' => [
              [1, '<div id="LC1" class="line" lang="swift"><span class="c1">// Swift example</span></div>'],
              [2, '<div id="LC1" class="line" lang="swift"><span class="kd">struct</span> <span class="kt">HelloWorld</span> <span class="p">{</span></div>'],
              [3, '<div id="LC1" class="line" lang="swift">    <span class="k">let</span> <span class="nv">name</span> <span class="o">=</span> <span class="s">"World"</span></div>'],
              [4, '<div id="LC1" class="line" lang="swift"></div>'],
              [5, '<div id="LC1" class="line" lang="swift">    <span class="kd">static</span> <span class="kd">func</span> <span class="nf">message</span><span class="p">()</span> <span class="p">{</span></div>'],
              [6, '<div id="LC1" class="line" lang="swift">        <span class="nf">print</span><span class="p">(</span><span class="s">"Hello, </span><span class="se">\\(</span><span class="k">self</span><span class="o">.</span><span class="n">name</span><span class="se">)</span><span class="s">"</span><span class="p">)</span></div>'],
              [7, '<div id="LC1" class="line" lang="swift">    <span class="p">}</span></div>'],
              [8, '<div id="LC1" class="line" lang="swift"><span class="p">}</span></div>']
            ]
          },
          {
            'function' => 'print',
            'lineNo' => 3,
            'filename' => 'hello_world.php',
              'context' => [
                [1, '<div id="LC1" class="line" lang="hack"><span class="c1">// PHP/Hack example</span></div>'],
                [2, '<div id="LC1" class="line" lang="hack"><span class="cp">&lt;?php</span></div>'],
                [3, '<div id="LC1" class="line" lang="hack"><span class="k">echo</span> <span class="s1">\'Hello, World!\'</span><span class="p">;</span></div>']
            ]
          },
          {
            'filename' => 'blank.txt'
          }
        ]
      )
    end
  end
end
