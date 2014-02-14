module PurityCounters
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def has_purity_counters(collection_name)
      scope :not_empty, -> {
        where("sfw_#{collection_name}_count > 0 OR sketchy_#{collection_name}_count > 0 OR nsfw_#{collection_name}_count > 0")
      }

      scope :not_empty_for_purities, -> (purities, sum_gte = 0) {
        purities = purities.map { |p| counter_name_for(p) }.join(' + ')
        where(["(#{purities}) >= ?", sum_gte])
      }

      define_singleton_method :counter_name_for do |purity|
        purity = purity.purity if purity.respond_to? :purity
        "#{purity}_#{collection_name}_count"
      end

      define_method :"#{collection_name}_count_for" do |purities|
        purities.map { |purity| read_attribute(self.class.counter_name_for(purity)) }.reduce(:+)
      end

      define_method :"#{collection_name}_count" do
        send "#{collection_name}_count_for", [:sfw, :sketchy, :nsfw]
      end
    end
  end
end
