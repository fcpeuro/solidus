# frozen_string_literal: true

require "singleton"
require "spree/core/class_constantizer"

module Spree
  # A class responsible for associating {Spree::Role} with a list of permission sets.
  #
  # @see Spree::PermissionSets
  #
  # @example Adding order, product, and user display to customer service users.
  #   Spree::RoleConfiguration.configure do |config|
  #     config.assign_permissions :customer_service, [
  #       Spree::PermissionSets::OrderDisplay,
  #       Spree::PermissionSets::UserDisplay,
  #       Spree::PermissionSets::ProductDisplay
  #     ]
  #   end
  class RoleConfiguration
    # An internal structure for the association between a role and a
    # set of permissions.
    class Role
      attr_reader :name, :permission_sets

      def initialize(name, permission_sets)
        @name = name
        @permission_sets = Spree::Core::ClassConstantizer::Set.new
        @permission_sets.concat permission_sets
      end
    end

    attr_accessor :roles

    # Given a CanCan::Ability, and a user, determine what permissions sets can
    # be activated on the ability, then activate them.
    #
    # This performs can/cannot declarations on the ability, and can modify its
    # internal permissions.
    #
    # @param ability [CanCan::Ability] the ability to invoke declarations on
    # @param user [#spree_roles] the user that holds the spree_roles association.
    def activate_permissions!(ability, user)
      permission_sets_for(user).each do |permission_set|
        permission_set.new(ability).activate!
      end
    end

    # Not public due to the fact this class is a Singleton
    # @!visibility private
    def initialize
      @roles = Hash.new do |hash, name|
        hash[name] = Role.new(name, Set.new)
      end
    end

    # Assign permission sets for a {Spree::Role} that has the name of role_name
    # @param role_name [Symbol, String] The name of the role to associate permissions with
    # @param permission_sets [Array<Spree::PermissionSets::Base>, Set<Spree::PermissionSets::Base>]
    #   A list of permission sets to activate if the user has the role indicated by role_name
    def assign_permissions(role_name, permission_sets)
      name = role_name.to_s

      roles[name].permission_sets.concat permission_sets
      roles[name]
    end

    private

    # Combines the permission sets configured in code (keyed by role name) with,
    # when {Spree::Config#activate_persisted_permission_sets} is enabled, the
    # permission sets persisted against the user's roles in the database.
    #
    # The returned {Spree::Core::ClassConstantizer::Set} dedupes by class name,
    # so a permission set present in both sources is activated only once.
    #
    # @param user [#spree_roles]
    # @return [Spree::Core::ClassConstantizer::Set]
    def permission_sets_for(user)
      combined = Spree::Core::ClassConstantizer::Set.new

      role_names = ["default"] | user.spree_roles.map(&:name)
      role_names.each { |role_name| combined.concat(roles[role_name].permission_sets) }

      if Spree::Config.activate_persisted_permission_sets
        combined.concat(persisted_permission_set_names(user))
      end

      combined
    end

    # The class names of the permission sets associated to the user's roles in
    # the database. Names that no longer resolve to a defined class (e.g. a
    # permission set removed from the codebase) are ignored.
    #
    # @param user [#spree_roles]
    # @return [Array<String>]
    def persisted_permission_set_names(user)
      return [] if user.spree_roles.empty?

      Spree::PermissionSet
        .joins(:roles)
        .where(spree_roles: {id: user.spree_roles.ids})
        .distinct
        .pluck(:set)
        .select { |set| set.present? && set.safe_constantize }
    end
  end
end
