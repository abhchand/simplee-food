module FeatureHelpers
  def expect_flash_message(msg)
    within('.flash__content') { expect(page).to have_content(msg) }
  end
end
