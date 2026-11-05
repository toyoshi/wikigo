module VersionsHelper
  def diff(content1, content2)
    changes = Diffy::Diff.new(content1, content2, 
                             )
    changes.to_s.present? ? changes.to_s(:html).html_safe : 'No Changes'
  end

  # Returns the body of a reified PaperTrail version as displayable HTML.
  #
  # The body_snapshot column holds the HTML captured when that version was
  # saved, so history shows the content the page actually had at that time.
  # Records versioned before the snapshot existed fall back to the live body.
  def version_body(version)
    return "" unless version
    version.try(:body_snapshot).presence || version.body.to_s
  end
end
