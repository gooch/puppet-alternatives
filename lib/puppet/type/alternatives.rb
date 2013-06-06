Puppet::Type.newtype(:alternatives) do

  feature :auto, "The alternative has an automatic option"

  newparam(:name, :isnamevar => true) do
    desc "The name of the alternative."
  end

  newproperty(:path) do
    desc "The path of the desired source for the given alternative"

    validate do |path|
      raise ArgumentError, "path must be a fully qualified path" unless path == 'auto' or absolute_path? path
    end
  end

  newproperty(:auto, :required_features => [:auto]) do
    desc "Use the automatic option for this alternative"

    newvalue(:true)
  end

  validate do
    if self[:auto] and self[:path]
      raise ArgumentError, "Only one of `auto` and `path` may be set"
    end
  end
end
