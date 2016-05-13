require 'spec_helper'

describe 'openshift3' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end
        let(:params) do
          {
            :masters => [
              {
                'name' => 'master01.example.com',
                'ip'   => '10.0.0.1',
              }
            ]
          }
        end

        context "openshift3 class without any parameters" do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('openshift3') }
        end
      end
    end
  end
end


