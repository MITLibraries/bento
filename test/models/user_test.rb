# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  email      :string           not null
#  uid        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'should not save user without uid' do
    user = User.new
    user.email = 'popcorn@example.com'

    assert_raises ActiveRecord::StatementInvalid do
      user.save
    end
  end

  test 'should not save user without email' do
    user = User.new
    user.uid = 'asdf1234'

    assert_raises ActiveRecord::StatementInvalid do
      user.save
    end
  end

  test 'should save valid user' do
    user = User.new
    user.email = 'popcorn@example.com'
    user.uid = 'asdf1234'
    assert user.save
  end

  test 'should create user from omniauth' do
    auth = OmniAuth::AuthHash.new(uid: '123', provider: 'example',
                                  info: { name: 'Orange Cat',
                                          email: 'ocat@example.com' })
    omniuser = User.from_omniauth(auth)
    assert_equal(omniuser.email, 'ocat@example.com')
  end
end
