class Project < ActiveRecord::Base
  
  has_and_belongs_to_many :tools
  
  def self.to_uri
    '/projects/'
  end
  
  validates_uniqueness_of :name, :slug
  before_validation :set_slug
  after_save do
    Tool.all(:conditions => '(SELECT COUNT(*) FROM "projects_tools" WHERE "projects_tools".tool_id = "tools".id LIMIT 1) < 1').each(&:delete)
  end
  validates_format_of :slug, :with => /^[0-9a-z_]+$/
  
  attr_protected :slug
  
  def to_uri
    '/projects/' + slug
  end
  
  def to_s
    name
  end
  
  def tools=(tools_list)
    return self.tool_ids=(tools_list.map(&:id)) if tools_list.kind_of? Array
    if tools_list.kind_of? String
      self.tools.clear
      return tools_list.downcase.split(' ').each do |tool_name|
        tool = Tool.find_by_name(tool_name) unless tool_name.blank?
        if tool
          self.tools.push tool
        else
          self.tools.build(:name => tool_name)
        end
      end
    end
    
  end
  
  def tools_with_joining
    JoiningArray.new(tools_without_joining)
  end
  
  alias_method_chain :tools, :joining
  
  def description_html
    BlueCloth::new(self[:description]).to_html
  end
  
  private
  
  def set_slug
    self.slug = name.downcase.gsub(/[^0-9a-z]/, '_').squeeze('_') if slug.blank?
  end
    
end