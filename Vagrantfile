# -*- mode: ruby -*-
# vi: set ft=ruby :
 
# read vm and puppet configurations from JSON files
nodes_config = (JSON.parse(File.read("nodes.json")))['nodes']
puppet_config  = (JSON.parse(File.read("puppet.json")))['puppet']
# nodes_config = (JSON.parse(File.read("nodes_pete.json")))['nodes']
# puppet_config  = (JSON.parse(File.read("puppet_pete.json")))['puppet']
# nodes_config = (JSON.parse(File.read("nodes_4.json")))['nodes']
# puppet_config  = (JSON.parse(File.read("puppet_4.json")))['puppet']

VAGRANTFILE_API_VERSION = "2"
domain = puppet_config[':domain']
environment = puppet_config[':environment']
box_environment = puppet_config[':box_environment']
env_puppet_version = puppet_config[':env_puppet_version']
if env_puppet_version =~ /^4/
  puppet_confdir = '/etc/puppetlabs/puppet'
  puppet_codedir = '/etc/puppetlabs/code'
  puppet_bin_dir = '/opt/puppetlabs/bin'
  facterbasepath = '/opt/puppetlabs/facter'
else
  puppet_confdir = '/etc/puppet'
  puppet_codedir = '/etc/puppet'
  puppet_bin_dir = '/usr/bin'
  facterbasepath = '/etc/facter'
end

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
    if puppet_config[':r10k_module_path']
      config.r10k.module_path = puppet_config[':r10k_module_path'] # the path to your Puppetfile, within the repo
    end
    puppetmaster_config.vm.host_name = puppet_config[':puppet_server']
    # set alias for hostmanager
    puppetmaster_config.hostmanager.aliases = %w(puppet)
    puppetmaster_config.vm.box = puppet_config[':box']
    if puppet_config[':ip']
      puppetmaster_config.vm.network "private_network", ip: puppet_config[':ip'], virtualbox__intnet: true
    else
      puppetmaster_config.vm.network "private_network", virtualbox__intnet: true
    end
    # setup a bridge to a local interface if specified
    # if puppet_config[':bridge']
    #   puppetmaster_config.vm.network "public_network", bridge: puppet_config[':bridge']
    # end
    # setup the usable port rage
    if puppet_config[':ports_from'] and puppet_config[':ports_to'] 
      puppetmaster_config.vm.usable_port_range = (puppet_config[':ports_from']..puppet_config[':ports_to'])
    # else
    #   puppetmaster_config.vm.usable_port_range = (2200..2250)
    end
    # configures all forwarding ports in JSON array
    if puppet_config[':ports']
      ports = puppet_config[':ports']
      ports.each do |port|
        puppetmaster_config.vm.network :forwarded_port, guest: port[':guest'], host:  port[':host']#, auto_correct: true
      end
    end
    # configures all synced folders in JSON array
    synced_folders = puppet_config[':synced_folders']
    if puppet_config[':synced_folders_type']
      synced_folders.each do |folder|
        puppetmaster_config.vm.synced_folder folder[':host'], folder[':guest'], type: puppet_config[':synced_folders_type']
      end
    else
      synced_folders.each do |folder|
        puppetmaster_config.vm.synced_folder folder[':host'], folder[':guest']
      end
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
      if puppet_config[':repo_collection'] and puppet_config[':repo_os']
        puppetmaster_config.vm.provision "shell", path: puppet_config[':repo_script'], args: [puppet_config[':repo_os'],puppet_config[':repo_collection']]
      else
        puppetmaster_config.vm.provision "shell", path: puppet_config[':repo_script'], args: puppet_config[':repo_os']
      end
    end
    # shell provision if set
    if puppet_config[':shell_provision_script']
      if puppet_config[':repo_collection']
        puppetmaster_config.vm.provision "shell", path: puppet_config[':shell_provision_script'], args: puppet_config[':repo_collection']
      else
        puppetmaster_config.vm.provision "shell", path: puppet_config[':shell_provision_script']
      end
    end
    # bootstrap shell provision if set
    # if puppet_config[':bootstrap_provision_script']
    #   puppetmaster_config.vm.provision "shell", path: puppet_config[':bootstrap_provision_script']
    # end

    # copy in hiera.yaml
    puppetmaster_config.vm.provision "shell",
      inline: "echo copying in hiera.yaml && cp /vagrant/puppet/hiera.yaml #{puppet_codedir}/hiera.yaml"
    puppetmaster_config.vm.provision "shell",
      inline: "echo installing hiera-eyaml && mkdir -p #{facterbasepath}/facts.d && cp /vagrant/puppet/local_facts.yaml #{facterbasepath}/facts.d"

    # set environmentpath
    if puppet_config[':environmentpath']
      environmentpath = puppet_config[':environmentpath']
      puppetmaster_config.vm.provision "shell",
        inline: "echo setting environmentpath && #{puppet_bin_dir}/puppet config set --section main environmentpath #{environmentpath}",
        run: "once"
    end
    # set basemodulepath
    if puppet_config[':basemodulepath']
      basemodulepath = puppet_config[':basemodulepath']
      puppetmaster_config.vm.provision "shell",
        inline: "echo setting basemodulepath && #{puppet_bin_dir}/puppet config set --section main basemodulepath #{basemodulepath}",
        run: "once"
    end
    # set autosign
    puppetmaster_config.vm.provision "shell",
      inline: "echo enabling autosign && #{puppet_bin_dir}/puppet config set --section master autosign true",
      run: "once"
    # set environment
    puppetmaster_config.vm.provision "shell",
      inline: "echo setting environment && #{puppet_bin_dir}/puppet config set --section agent environment #{environment}"#,
      # run: "once"
    # install hiera-eyaml
    puppetmaster_config.vm.provision "shell",
      inline: "echo installing hiera-eyaml && puppetserver gem install hiera-eyaml",
      run: "once"

    # puppet provision if set
    if puppet_config[':puppet_provision'] == true
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
      end # end puppet apply
    end
    ## puppetmaster agent settings if set
    if puppet_config[':puppet_server_provision'] == true
      puppetmaster_config.vm.provision :puppet_server do |puppet|
        if puppet_config[':facter']
          puppet.facter = puppet_config[':facter']
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
      end # puppet agent settings
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
      # set box environment if set for this node
      # otherwise use box_environment from global
      if node_values[':environment']
        node_environment = node_values[':environment']
      else
        node_environment = puppet_config[':box_environment']
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
        node_config.vm.network :private_network, ip: node_values[':ip'], virtualbox__intnet: true
      else
        node_config.vm.network :private_network, virtualbox__intnet: true
      end
      # # setup a bridge to a local interface if specified
      # if node_values[':bridge']
      #   node_config.vm.network :public_network, bridge: node_values[':bridge']
      # end
      # setup the usable port rage
      if puppet_config[':ports_from'] and puppet_config[':ports_to'] 
        node_config.vm.usable_port_range = (puppet_config[':ports_from']..puppet_config[':ports_to'])
      # else
      #   node_config.vm.usable_port_range = (2200..2250)
      end
      # configures all forwarding ports in JSON array
      if node_values[':ports']
        ports = node_values[':ports']
        ports.each do |port|
          node_config.vm.network "forwarded_port", guest: port[':guest'], host:  port[':host']#, auto_correct: true
        end
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
      if node_values[':repo_script']
        if puppet_config[':repo_collection'] and node_values[':repo_os']
          node_config.vm.provision "shell", path: node_values[':repo_script'], args: [node_config[':repo_os'], puppet_config[':repo_collection']]
        else
          node_config.vm.provision "shell", path: node_values[':repo_script'], args: node_config[':repo_os']
        end
      elsif puppet_config[':repo_script']
        if puppet_config[':repo_collection'] and node_values[':repo_os']
          node_config.vm.provision "shell", path: node_values[':repo_script'], args: [node_config[':repo_os'], puppet_config[':repo_collection']]
        else
          node_config.vm.provision "shell", path: node_values[':repo_script'], args: node_config[':repo_os']
        end
      end
      ## provision with shell scipt if set
      if puppet_config[':box_shell_provision_script']
        if puppet_config[':repo_collection']
          node_config.vm.provision "shell", path: puppet_config[':box_shell_provision_script'], args: puppet_config[':repo_collection']
        else
          node_config.vm.provision "shell", path: puppet_config[':box_shell_provision_script']
        end
      end
      ## puppet agent settings
      node_config.vm.provision :puppet_server do |puppet|
        # set facts if set for this node
        # otherwise use facts from global
        if node_values[':facter']
          puppet.facter = node_values[':facter']
        else
          puppet.facter = puppet_config[':facter']
        end
        if node_values[':puppet_options']
          puppet.options = node_values[':puppet_options']
        else
          puppet.options = [
            '--verbose',
            '--show_diff',
            '--environment=' + node_environment,
            #'--noop',
            #'--debug',
            #'--parser future',
          ]
        end
      end # puppet agent settings
      if Vagrant.has_plugin?("vagrant-triggers")
        # every time a machine is destroyed, delete the certs and remove the resources from puppetdb
        node_config.trigger.after [:destroy] do
            target = @machine.name.to_s
            puppetmaster = "puppetmaster"
            if target != puppetmaster
              system("vagrant ssh #{puppetmaster} -c 'sudo #{puppet_bin_dir}/puppet cert clean #{target}.#{domain}'" )
              system("vagrant ssh #{puppetmaster} -c 'sudo #{puppet_bin_dir}/puppet node deactivate #{target}.#{domain}'" )
            end
        end
      else
        abort("Please install the triggers plugin, vagrant plugin install vagrant-triggers")
      end
    end
  end
end
