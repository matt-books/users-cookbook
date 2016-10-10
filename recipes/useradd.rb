
system_users = node.default[:users]
start_uid = node.default[:starting_uid]
home_prefix = node.default[:home_dir]

# load the config data from attributes
i = 0
system_users.each do |named_section|
	$username = String
	pubkeys = Array.new
	$passhash = String
	if named_section.is_a?(Array) then # on a users' section
		named_section.each do |a_user|
			if a_user.is_a?(String) then # must be the user name
				$username = a_user
			end
			if a_user.is_a?(Chef::Node::VividMash) then # must be the ssh keys
				$passhash = a_user[:encrypted_password]
				a_user[:ssh_pubkeys].each do |sshkey|
					pubkeys.push(sshkey[1])
				end
			end
		end
	end

	### Start Cookbook DSL for each User

	# create user
	user $username do
		username	$username
		uid         start_uid + i
		gid         'users'
		home        "#{home_prefix}/#{$username}"
		shell		'/bin/bash'
		password    $passhash
		action 		:create
	end

	# confirm home dir for amazon
	directory "#{home_prefix}/#{$username}" do
		owner 		$username
		group 		'users'
		mode 		'0700'
		action 		:create
	end

	# create ssl dir
	directory "#{home_prefix}/#{$username}/.ssh" do
		owner 		$username
		group 		'users'
		mode  		'0700'
		action 		:create
	end

	# add public key(s) to authorized_keys
	template "#{home_prefix}/#{$username}/.ssh/authorized_keys" do
		variables(  :sshkeys => pubkeys )
		source 		'authorized_keys.erb'
		owner		$username
		group		'users'
		mode		'0600'
		action		:create
	end

	# give sudo by adding to wheel group
	group 'wheel' do
		action		:modify
		members 	$username
		append  	true
	end

	# .bash_profile and .bashrc
	cookbook_file "#{home_prefix}/#{$username}/.bash_profile" do
		source 		'bash_profile'
		owner 		$username
		group 		'users'
		mode  		'0644'
		action 		:create
	end

    cookbook_file "#{home_prefix}/#{$username}/.bashrc" do
        source 		'bashrc'
        owner 		$username
        group 		'users'
        mode  		'0644'
        action 		:create
    end

	i += 1
end # end loop on :users

# Uncomment wheel group for sudoers
cookbook_file '/etc/sudoers' do
	source 'sudoers'
	owner  'root'
	group  'root'
	mode   '0440'
	action :create
end
