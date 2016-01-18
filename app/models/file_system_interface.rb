class FileSystemInterface

  # Lock a package from being writable
  def self.lock(package_id)
    if !Rails.env.test?
      sudo_cmd(env: {"DLIVER_PACKAGES_DIR" => APP_CONFIG['store_path']}, cmd: "#{Rails.root}/scripts/lock.sh", params: [package_id])
    end
  end

  # Unlock a package to make it writable
  def self.unlock(package_id)
    if !Rails.env.test?
      sudo_cmd(env: {"DLIVER_PACKAGES_DIR" => APP_CONFIG['store_path'], "DLIVER_PACKAGES_GROUP" => APP_CONFIG['file_access_group']}, cmd: "#{Rails.root}/scripts/unlock.sh", params: [package_id])
    end
  end

  # Run a cli command as sudo
  def self.sudo_cmd(env: {}, cmd:, params: [])
    IO.popen(env, ["sudo", "-E", cmd]+params) do |r| 
      puts r.read
    end
  end
end
