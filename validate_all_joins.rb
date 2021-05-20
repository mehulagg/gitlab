traversed = {}

ApplicationRecord.descendants.each do |klass|
  # puts "Testing #{klass}..."
  type = traversed[klass.polymorphic_name] ||= {}
  ci_klass = klass < Ci::ApplicationRecord

  klass.reflections.each do |key, desc|
    options = desc.options
    target_klass = desc.klass
    target_ci_klass = target_klass < Ci::ApplicationRecord

    next if type.include?(key)

    if options[:through]
      type[key] = desc

      through_desc = klass.reflections[options[:through].to_s]
      through_klass = through_desc.klass
      through_ci_klass = through_klass < Ci::ApplicationRecord

      if through_ci_klass == target_ci_klass
        puts "Through: Invalid disable_joins: #{klass}.#{key} to #{target_klass}" if options[:disable_joins]
      else
        puts "Through: Missing disable_joins: #{klass}.#{key} to #{target_klass}" unless options[:disable_joins]
      end
    else
      if through_ci_klass == target_ci_klass
        puts "General: Invalid disable_joins: #{klass}.#{key} to #{target_klass}" if options[:disable_joins]
      else
        puts "General: Missing disable_joins: #{klass}.#{key} to #{target_klass}" unless options[:disable_joins]
      end
    end
  rescue => e
    puts "Ex: #{klass}.#{key}: #{e.message}"
  end
end
