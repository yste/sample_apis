FactoryBot.define do
  factory :base_user_params, class: User do
    email {"sample@example.com"}
    password {"hogehoge"}
    password_confirmation {"hogehoge"}
  end

  factory :empty_pass_user_params, class: User do
    email {"sample@hogehoge.com"}
    password {""}
    password_confirmation {""}
  end

  factory :unmatch_pass_user_params, class: User do
    email {"sample@hogehoge.com"}
    password {"hogehoge"}
    password_confirmation {"hogefuga"}
  end

  factory :known_user_params, class: User do
    email {"test@example.com"}
    password {"hogehoge"}
  end

  factory :base_user, class: User do
    email {"test@example.com"}
    password {"hogehoge"}
  end

  factory :base_user2, class: User do
    email {"sample@example.com"}
    password {"hogehoge"}
  end

  factory :base_user3, class: User do
    email {"hogehoge@example.com"}
    password {"hogehoge"}
  end

  factory :email_error_user, class: User do
    email {"hogehoge"}
    password {"hogefuga"}
  end
end
