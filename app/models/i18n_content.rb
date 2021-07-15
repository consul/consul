class I18nContent < ApplicationRecord
  validates :key, uniqueness: true

  translates :value, touch: true
  globalize_accessors

  # flat_hash returns a flattened hash, a hash with a single level of
  # depth in which each key is composed from the keys of the original
  # hash (whose value is not a hash) by typing in the key of the route
  # from the first level of the original hash
  #
  # Examples:
  #
  # hash = {
  #   'key1' => 'value1',
  #   'key2' => { 'key3' => 'value2',
  #               'key4' => { 'key5' => 'value3' } }
  # }
  #
  # I18nContent.flat_hash(hash) = {
  #   'key1' => 'value1',
  #   'key2.key3' => 'value2',
  #   'key2.key4.key5' => 'value3'
  # }
  #
  # I18nContent.flat_hash(hash, 'string') = {
  #   'string.key1' => 'value1',
  #   'string.key2.key3' => 'value2',
  #   'string.key2.key4.key5' => 'value3'
  # }
  #
  # I18nContent.flat_hash(hash, 'string', { 'key6' => 'value4' }) = {
  #   'key6' => 'value4',
  #   'string.key1' => 'value1',
  #   'string.key2.key3' => 'value2',
  #   'string.key2.key4.key5' => 'value3'
  # }

  def self.flat_hash(input, path = nil, output = {})
    return output.update({ path => input }) unless input.is_a? Hash

    input.map { |key, value| flat_hash(value, [path, key].compact.join("."), output) }
    output
  end

  def self.content_for(tab)
    translations_for(tab).map do |string|
      I18nContent.find_or_initialize_by(key: string)
    end
  end

  def self.translations_for(tab)
    if tab.to_s == "basic"
      basic_translations
    elsif tab.to_s == "machine_learning"
      machine_learning_translations
    else
      flat_hash(translations_hash_for(tab)).keys
    end
  end

  def self.translations_hash_for(tab)
    I18n.backend.send(:init_translations) unless I18n.backend.initialized?

    I18n.backend.send(:translations)[I18n.locale].select do |key, _translations|
      key.to_s == tab.to_s
    end
  end

  def self.basic_translations
    %w[
      debates.index.section_footer.title
      debates.index.section_footer.description
      debates.index.section_footer.help_text_1
      debates.index.section_footer.help_text_2
      debates.new.info
      debates.new.info_link
      debates.new.more_info
      debates.new.recommendation_one
      debates.new.recommendation_two
      debates.new.recommendation_three
      debates.new.recommendation_four
      debates.new.recommendations_title
      proposals.index.section_footer.title
      proposals.index.section_footer.description
      proposals.new.more_info
      proposals.new.recommendation_one
      proposals.new.recommendation_two
      proposals.new.recommendation_three
      proposals.new.recommendations_title
      polls.index.section_footer.title
      polls.index.section_footer.description
      legislation.processes.index.section_footer.title
      legislation.processes.index.section_footer.description
      budgets.index.section_footer.title
      budgets.index.section_footer.description
    ]
  end

  def self.machine_learning_translations
    %w[
      admin.machine_learning.title
      machine_learning.comments_summary
      machine_learning.info_text
      admin.machine_learning.comments_summary
      admin.machine_learning.comments_summary_description
      admin.machine_learning.related_content
      admin.machine_learning.related_content_description
      admin.machine_learning.tags
      admin.machine_learning.tags_description
    ]
  end

  def self.translations_hash(locale)
    Rails.cache.fetch(translation_class.where(locale: locale)) do
      all.map do |content|
        [content.key, translation_class.find_by(i18n_content_id: content, locale: locale)&.value]
      end.to_h
    end
  end
end
