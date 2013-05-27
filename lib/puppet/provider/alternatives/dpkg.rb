Puppet::Type.type(:alternatives).provide(:dpkg) do

  commands :update => '/usr/sbin/update-alternatives'

  has_feature :auto

  # Return all instances for this provider
  #
  # @return [Array<Puppet::Type::Alternatives::ProviderDpkg>] A list of all current provider instances
  def self.instances
    all.map { |name, attributes| new(:name => name, :path => attributes[:path]) }
  end

  # Generate a hash of hashes containing a link name and associated properties
  # @return [Hash<String, Hash<Symbol, String>>]
  def self.all
    output = update('--get-selections')

    output.split(/\n/).inject({}) do |hash, line|
      name, source, path = line.split(/\s+/)
      hash[name] = {:source => source, :path => path, :auto => (source == 'auto')}
      hash
    end
  end

  # Retrieve the current path link
  def path
    name = @resource.value(:name)
    self.class.all[name][:path]
  end

  # @param [String] newpath The path to use as the new alternative link
  def path=(newpath)
    name = @resource.value(:name)
    update('--set', name, newpath)
  end

  # @return [Boolean] If the alternative is using the automatic option
  def auto
    output = update('--display', @resource.value(:name))
    first = output.split("\n").first

    if first.match /auto mode/
      true
    elsif first.match /manual mode/
      false
    elsif
      raise Puppet::Error, "Could not determine if #{self} is in auto or manual mode"
    end
  end

  def auto=(_)
    update('--auto', @resource.value(:name))
  end
end
