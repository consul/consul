module Abilities
  class Moderation
    include CanCan::Ability

    def initialize(user)
      merge Abilities::Common.new(user)

      can :read, Organization
      can(:verify, Organization) { |o| !o.verified? }
      can(:reject, Organization) { |o| !o.rejected? }

      can :read, Comment

      can :hide, Comment, hidden_at: nil
      cannot :hide, Comment, user_id: user.id

      can :ignore_flag, Comment, ignored_flag_at: nil, hidden_at: nil
      cannot :ignore_flag, Comment, user_id: user.id

      can :moderate, Comment
      cannot :moderate, Comment, user_id: user.id

      can :hide, Debate, hidden_at: nil
      cannot :hide, Debate, author_id: user.id

      can :ignore_flag, Debate, ignored_flag_at: nil, hidden_at: nil
      cannot :ignore_flag, Debate, author_id: user.id

      can :moderate, Debate
      cannot :moderate, Debate, author_id: user.id

      can :hide, Proposal, hidden_at: nil

      can :ignore_flag, Proposal, ignored_flag_at: nil, hidden_at: nil
      cannot :ignore_flag, Proposal, author_id: user.id

      can :moderate, Proposal

      can :hide, Legislation::Proposal, hidden_at: nil
      cannot :hide, Legislation::Proposal, author_id: user.id

      can :ignore_flag, Legislation::Proposal, ignored_flag_at: nil, hidden_at: nil
      cannot :ignore_flag, Legislation::Proposal, author_id: user.id

      can :moderate, Legislation::Proposal
      cannot :moderate, Legislation::Proposal, author_id: user.id

      can :hide, User
      cannot :hide, User, id: user.id

      can :soft_block, User
      cannot :soft_block, User, id: user.id

      can :block, User
      cannot :block, User, id: user.id

      can :hide, ProposalNotification, hidden_at: nil
      cannot :hide, ProposalNotification, author_id: user.id

      can :ignore_flag, ProposalNotification, ignored_at: nil, hidden_at: nil
      cannot :ignore_flag, ProposalNotification, author_id: user.id

      can :moderate, ProposalNotification
      cannot :moderate, ProposalNotification, author_id: user.id

      can :index, ProposalNotification

      can :hide, Budget::Investment, hidden_at: nil
      cannot :hide, Budget::Investment, author_id: user.id

      can :ignore_flag, Budget::Investment, ignored_flag_at: nil, hidden_at: nil
      cannot :ignore_flag, Budget::Investment, author_id: user.id

      can :moderate, Budget::Investment
      cannot :moderate, Budget::Investment, author_id: user.id
    end
  end
end
