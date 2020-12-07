require "rails_helper"

describe LinkListHelper do
  describe "#link_list" do
    it "returns an empty string with an empty list" do
      expect(helper.link_list).to eq ""
    end

    it "returns nothing with a list of nil elements" do
      expect(helper.link_list(nil, nil)).to eq ""
    end

    it "generates a list of links" do
      list = helper.link_list(["Home", "/"], ["Info", "/info"], class: "menu")

      expect(list).to eq '<ul class="menu"><li><a href="/">Home</a></li><li><a href="/info">Info</a></li></ul>'
      expect(list).to be_html_safe
    end

    it "accepts options for links" do
      render helper.link_list(["Home", "/", class: "root"], ["Info", "/info", id: "info"])

      expect(page).to have_css "a", count: 2
      expect(page).to have_css "a.root", count: 1, exact_text: "Home"
      expect(page).to have_css "a#info", count: 1, exact_text: "Info"
    end

    it "ignores nil entries" do
      render helper.link_list(["Home", "/", class: "root"], nil, ["Info", "/info", id: "info"])

      expect(page).to have_css "a", count: 2
      expect(page).to have_css "a.root", count: 1, exact_text: "Home"
      expect(page).to have_css "a#info", count: 1, exact_text: "Info"
    end

    it "accepts an optional condition to check the active element" do
      render helper.link_list(
        ["Home", "/", false],
        ["Info", "/info", true],
        ["Help", "/help"]
      )

      expect(page).to have_css "li", count: 3
      expect(page).to have_css "li[aria-current='true']", count: 1, exact_text: "Info"
    end

    it "allows passing both the active condition and link options" do
      render helper.link_list(
        ["Home", "/", false, class: "root"],
        ["Info", "/info", true, id: "info"],
        ["Help", "/help", rel: "help"]
      )

      expect(page).to have_css "li", count: 3
      expect(page).to have_css "li[aria-current='true']", count: 1, exact_text: "Info"

      expect(page).to have_css "a.root", count: 1, exact_text: "Home"
      expect(page).to have_css "a#info", count: 1, exact_text: "Info"
      expect(page).to have_css "a[rel='help']", count: 1, exact_text: "Help"
    end

    it "accepts the content of the list item as a parameter" do
      list = helper.link_list(["Home", "/"], "Something")

      expect(list).to eq '<ul><li><a href="/">Home</a></li><li>Something</li></ul>'
      expect(list).to be_html_safe
    end

    it "accepts safe HTML as the content of the list item" do
      list = helper.link_list(["Home", "/"], helper.tag.span("Something"))

      expect(list).to eq '<ul><li><a href="/">Home</a></li><li><span>Something</span></li></ul>'
      expect(list).to be_html_safe
    end
  end

  attr_reader :content

  def render(content)
    @content = content
  end

  def page
    Capybara::Node::Simple.new(content)
  end
end
