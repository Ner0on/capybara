# frozen_string_literal: true

module Capybara
  module Plugins
    class ReactSelect
      def select(scope, value, **options)
        select = find_react_select(scope, value, options).click
        option = scope.find(:react_select_option, value)
        option.click
      end

      def unselect(scope, value, **options)
        select = find_react_select(scope, value, options)
        raise Capybara::UnselectNotAllowed, 'Cannot unselect option from single select box.' unless select2.has_css?('.select2-selection--multiple')
        select.click
        option = scope.find(:react_select_option, value)
        option.click
      end

    private

      def find_react_select(scope, value, from: nil, **options)
        if from
          scope.find(:react_select, from, options.merge(visible: false))
        else
          select = scope.find(:option, value, options).ancestor(:css, 'select', visible: false)
          select.find(:xpath, XPath.next_sibling(:span)[XPath.attr(:class).contains_word('react-select')][XPath.attr(:class).contains_word('react-select-container')])
        end
      end
    end
  end
end

Capybara.add_selector(:react_select) do
  xpath do |locator, **options|
    XPath.css('.select__control')[XPath.following_sibling(:input)[XPath.attr(:name) == locator]]
  end
end

Capybara.add_selector(:react_select_option) do
  xpath do |locator|
    xpath = XPath.anywhere(:div)[XPath.attr(:class).contains_word('select__menu')]
    xpath = xpath.descendant(:div)[XPath.attr(:class).contains_word('select__option')]
    xpath = xpath[XPath.string.n.is(locator.to_s)] unless locator.nil?
    xpath
  end
end

Capybara.register_plugin(:react_select, Capybara::Plugins::ReactSelect.new)
