# -*- mode: ruby -*-
# vi: set ft=ruby :
 
# read vm and puppet configurations from JSON files
nodes_config = (JSON.parse(File.read("nodes.json")))['nodes']
puppet_config  = (JSON.parse(File.read("puppet.json")))['puppet']

VAGRANTFILE_API_VERSION = "2"
domain = puppet_config[':domain']
environment = puppet_config[':environment']

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # setup hostmaster plugin
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = false
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true
  ## puppet_install plugin if enabled
  if puppet_config[':puppet_install_version']
    config.puppet_install.puppet_version = puppet_config[':puppet_install_version']
  end
  
  ## A regular vm block for puppetmaster
  config.vm.define :puppetmaster do |puppetmaster_config|
    # R10k settings
    if puppet_config[':r10k_puppet_dir']
      config.r10k.puppet_dir = puppet_config[':r10k_puppet_dir'] # the parent directory that contains your module directory and Puppetfile
    end
    if puppet_config[':r10k_puppetfile_path']
      config.r10k.puppetfile_path = puppet_config[':r10k_puppetfile_path'] # the path to your Puppetfile, within the repo
    end
    puppetmaster_config.vm.host_name = puppet_config[':puppet_server']
    # set alias for hostmanager
    puppetmaster_config.hostmanager.aliases = %w(puppet)
    puppetmaster_config.vm.box = puppet_config[':box']
    puppetmaster_config.vm.network "private_network", ip: puppet_config[':ip'], virtualbox__intnet: true
    # configures all forwarding ports in JSON array
    if puppet_config[':ports']
      ports = puppet_config[':ports']
      ports.each do |port|
        puppetmaster_config.vm.network :forwarded_port,
          host:  port[':host'],
          guest: port[':guest'],
          id:    port[':id']
      end
    end
    # configures all synced folders in JSON array
    synced_folders = puppet_config[':synced_folders']
    synced_folders.each do |folder|
      puppetmaster_config.vm.synced_folder folder[':host'], folder[':guest']
    end
    puppetmaster_config.vm.provider 'virtualbox' do |vb|
      vb.memory = puppet_config[':memory']
      vb.cpus = puppet_config[':cores']
    end
    puppetmaster_config.vm.provider 'vmware_fusion' do |v|
      v.vmx["hard-disk.hostBuffer"] = "disabled"
      v.vmx["memsize"] = puppet_config[':memory']
      v.vmx["numvcpus"] = puppet_config[':cores']
    end
    ## setup repos
    if puppet_config[':repo_script']
      puppetmaster_config.vm.provision "shell", path: puppet_config[':repo_script']
    end
    # shell provision if set
    if puppet_config[':shell_provision_script']
      puppetmaster_config.vm.provision "shell", path: puppet_config[':shell_provision_script']
    end
    puppetmaster_config.vm.provision :puppet do |puppet|
      if puppet_config[':hiera_config_path']
        puppet.hiera_config_path = puppet_config[':hiera_config_path']
      end
      if puppet_config[':manifests_path']
        puppet.manifests_path = puppet_config[':manifests_path']
      end
      if puppet_config[':manifest_file']
        puppet.manifest_file = puppet_config[':manifest_file']
      end
      if puppet_config[':facter']
        puppet.facter = puppet_config[':facter']
      end
      if puppet_config[':module_path']
        puppet.module_path = puppet_config[':module_path']
      end
      if puppet_config[':puppet_options']
        puppet.options = puppet_config[':puppet_options']
      else
        puppet.options = [
          '--verbose',
          '--show_diff',
          '--environment=' + puppet_config[':environment'],
          #'--noop',
          #'--debug',
          #'--parser future',
        ]
      end
    end
  end

  nodes_config.each do |node|
    node_name   = node[0] # name of node
    node_values = node[1] # content of node
 
    config.vm.define node_name do |node_config|
      # set the box to use from nodes config or puppet config
      if node_values[':box']
        node_config.vm.box = node_values[':box']
      else
        node_config.vm.box = puppet_config[':node_box']
      end
      # configures all forwarding ports in JSON array
      if node_values[':ports']
        ports = node_values[':ports']
        ports.each do |port|
          node_config.vm.network :forwarded_port,
            host:  port[':host'],
            guest: port[':guest'],
            id:    port[':id']
        end
      end
      # configures all synced folders in JSON array
      if node_values[':synced_folders']
        synced_folders = node_values[':synced_folders']
        synced_folders.each do |folder|
          node_config.vm.synced_folder folder[':host'], folder[':guest']
        end
      end
      # set alias for hostmanager
      node_config.hostmanager.aliases = node_values[':node']
      # setup hostname, IP,ram and cores
      node_config.vm.hostname = node_values[':node'] + '.' + puppet_config[':domain']
      if node_values[':ip']
        node_config.vm.network :private_network, ip: node_values[':ip']
      end
      if node_values[':ram']
        node_config.vm.provider 'virtualbox' do |vb|
          vb.memory = node_values[':ram']
        end
        node_config.vm.provider 'vmware_fusion' do |v|
          v.vmx["memsize"] = node_values[':ram']
        end
      else
        node_config.vm.provider 'virtualbox' do |vb|
          vb.memory = 256
        end
        node_config.vm.provider 'vmware_fusion' do |v|
          v.vmx["memsize"] = 256
        end
      end
      if node_values[':cores']
        node_config.vm.provider 'virtualbox' do |vb|
          vb.cpus = node_values[':cores']
        end
        node_config.vm.provider 'vmware_fusion' do |v|
          v.vmx["numvcpus"] = node_values[':cores']
        end
      else
        node_config.vm.provider 'virtualbox' do |vb|
          vb.cpus = 1
        end
        node_config.vm.provider 'vmware_fusion' do |v|
          v.vmx["numvcpus"] = 1
        end
      end
      ## setup repos
      if puppet_config[':repo_script']
        node_config.vm.provision "shell", path: puppet_config[':repo_script']
      end
      ## provision with shell scipt if set
      if puppet_config[':box_shell_provision_script']
        node_config.vm.provision "shell", path: puppet_config[':box_shell_provision_script']
      end
      ## puppet agent settings
      node_config.vm.provision :puppet_server do |puppet|
        if node_values[':facter']
          puppet.facter = node_values[':facter']
        end
        puppet.puppet_server = puppet_config[':puppet_server']
        if node_values[':puppet_options']
          puppet.options = node_values[':puppet_options']
        else
          puppet.options = [
            '--verbose',
            '--show_diff',
            '--environment=' + puppet_config[':environment'],
            #'--noop',
            #'--debug',
            #'--parser future',
          ]
        end
      end # puppet agent settings
    end
  end
end
