class StaticController < ApplicationController
  def terms
  end

  def privacy
  end

  def faq
  end

  def sitemap
    %x[rake sitemap:refresh]
  end
end
