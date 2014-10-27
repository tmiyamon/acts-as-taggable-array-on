module ActsAsTaggableArrayOn
  class Parser
    def parse tags
      case tags
      when String
        tags.split(/[ ]*,[ ]*/)
      else
        tags
      end
    end
  end

  def self.parser
    @parser ||= Parser.new
  end
end
