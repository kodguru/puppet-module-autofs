require 'spec_helper'

describe 'autofs' do

  describe 'package' do
    it 'should install autofs' do
      should contain_package('autofs').with_ensure('installed')
    end
    it 'should start service' do
      should contain_service('autofs').with_name('autofs')
      should contain_service('autofs').with_ensure('running')
      should contain_service('autofs').with_enable(true)
    end
  end

  describe 'sysconfig' do
    context 'should provide correct default values' do
      it 'for timeout' do
        should contain_file('autofs_sysconfig').with_content(/^\s*TIMEOUT=600$/)
      end
      it 'for negative_timeout' do
        should contain_file('autofs_sysconfig').with_content(/^\s*NEGATIVE_TIMEOUT=60$/)
      end
      it 'for mount_wait' do
        should contain_file('autofs_sysconfig').with_content(/^\s*MOUNT_WAIT=-1$/)
      end
      it 'for umount_wait' do
        should contain_file('autofs_sysconfig').with_content(/^\s*UMOUNT_WAIT=12$/)
      end
      it 'for browse_mode' do
        should contain_file('autofs_sysconfig').with_content(/^\s*BROWSE_MODE="NO"$/)
      end
      it 'for mount_nfs_default_protocol' do
        should contain_file('autofs_sysconfig').with_content(/^\s*MOUNT_NFS_DEFAULT_PROTOCOL=4$/)
      end
      it 'for append_options' do
        should contain_file('autofs_sysconfig').with_content(/^\s*APPEND_OPTIONS="yes"$/)
      end
      it 'for logging' do
        should contain_file('autofs_sysconfig').with_content(/^\s*LOGGING="none"$/)
      end
    end
    context 'should provide correct specified values' do
      let :params do
        {
          :browse_mode => 'YES',
          :timeout     => '1200',
          :negative_timeout => '120',
          :mount_wait => '1',
          :umount_wait => '10',
          :mount_nfs_default_protocol => '3',
          :append_options => 'no',
          :logging => 'debug',
        }
      end
      it 'for timeout' do
        should contain_file('autofs_sysconfig').with_content(/^\s*TIMEOUT=1200$/)
      end
      it 'for negative_timeout' do
        should contain_file('autofs_sysconfig').with_content(/^\s*NEGATIVE_TIMEOUT=120$/)
      end
      it 'for mount_wait' do
        should contain_file('autofs_sysconfig').with_content(/^\s*MOUNT_WAIT=1$/)
      end
      it 'for umount_wait' do
        should contain_file('autofs_sysconfig').with_content(/^\s*UMOUNT_WAIT=10$/)
      end
      it 'for browse_mode' do
        should contain_file('autofs_sysconfig').with_content(/^\s*BROWSE_MODE="YES"$/)
      end
      it 'for mount_nfs_default_protocol' do
        should contain_file('autofs_sysconfig').with_content(/^\s*MOUNT_NFS_DEFAULT_PROTOCOL=3$/)
      end
      it 'for append_options' do
        should contain_file('autofs_sysconfig').with_content(/^\s*APPEND_OPTIONS="no"$/)
      end
      it 'for logging' do
        should contain_file('autofs_sysconfig').with_content(/^\s*LOGGING="debug"$/)
      end
    end
  end

end
