module VersionsHelper
  def diff(content1, content2)
    changes = Diffy::Diff.new(content1, content2, 
                             )
    changes.to_s.present? ? changes.to_s(:html).html_safe : 'No Changes'
  end
end
