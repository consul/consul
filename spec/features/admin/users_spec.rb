require 'rails_helper'

feature 'Admin users' do

  background do
    @admin = create(:administrator)
    @user  = create(:user, username: 'Jose Luis Balbin')
    login_as(@admin.user)
    visit admin_users_path
  end

  scenario 'Index' do
    expect(page).to have_content @user.name
    expect(page).to have_content @user.email
    expect(page).to have_content @admin.name
    expect(page).to have_content @admin.email
  end

  scenario 'Search' do
    fill_in :search, with: "Luis"
    click_button 'Search'

    expect(page).to have_content @user.name
    expect(page).to have_content @user.email
    expect(page).to_not have_content @admin.name
    expect(page).to_not have_content @admin.email
  end
end

