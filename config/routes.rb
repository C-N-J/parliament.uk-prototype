require_relative '../app/lib/ext/action_dispatch/routing/mapper.rb'

Rails.application.routes.draw do
  id_format_regex = self.class::ID_FORMAT_REGEX

  ### Root ###
  # /
  root 'home#index'

  ### People ###
  # /people (multiple 'people' scope)
  scope '/people', as: 'people' do
    build_default_routes('people', current: false)
    listable('people#a_to_z', 'people#letters')

    # /people/members
    build_members_routes('people', current: true)
  end

  # /people (single 'person' scope)
  scope '/people', as: 'person' do
    # /people/:person_id
    scope '/:person_id' do
      get '/', to: 'people#show', person_id: id_format_regex

      # /people/:person_id/constituencies
      build_root_and_current_routes('people', 'constituencies')

      get '/contact-points', to: 'people#contact_points'

      # /people/:person_id/houses
      build_root_and_current_routes('people', 'houses')

      # /people/:person_id/parties
      build_root_and_current_routes('people', 'parties')
    end

    # Allow lookups - but ensure they are SECOND in the routes list after /people/:person_id
    lookupable('people#lookup_by_letters')
  end

  ### Parties ###
  # /parties (multiple 'parties' scope)
  scope '/parties', as: 'parties' do
    build_default_routes('parties', postcode: false)
    listable('parties#a_to_z', 'parties#letters')
  end

  # /parties (single 'party' scope)
  scope '/parties', as: 'party' do
    # /parties/:party_id
    scope '/:party_id' do
      get '/', to: 'parties#show', party_id: id_format_regex

      # /parties/:party_id/members
      build_members_routes('parties', current: true)
    end

    # Allow lookups - but ensure they are SECOND in the routes list after /parties/:party_id
    lookupable('parties#lookup_by_letters')
  end

  ### Postcodes ###
  # /postcodes (multiple 'postcodes' scope)
  scope '/postcodes', as: 'postcodes' do
    get '/', to: 'postcodes#index'
    post '/lookup', to: 'postcodes#lookup'
  end

  # /postcodes (single 'postcode' scope)
  scope '/postcodes', as: 'postcode' do
    # /postcodes/:postcode
    scope '/:postcode' do
      get '/', to: 'postcodes#show'
    end
  end

  ### Constituencies ###
  # /constituencies (multiple 'constituencies' scope)
  scope '/constituencies', as: 'constituencies' do
    build_default_routes('constituencies', current: false)
    listable('constituencies#a_to_z', 'constituencies#letters')

    # /constituencies/current
    scope '/current', as: 'current' do
      get '/', to: 'constituencies#current'

      listable('constituencies#a_to_z_current', 'constituencies#current_letters')
    end
  end

  # /constituencies (single 'constituency' scope)
  scope '/constituencies', as: 'constituency' do
    # /constituencies/:constituency_id
    scope '/:constituency_id' do
      get '/', to: 'constituencies#show', constituency_id: id_format_regex
      get '/contact-point', to: 'constituencies#contact_point'
      get '/map', to: 'constituencies#map'

      # /constituencies/:constituency_id/members
      build_root_and_current_routes('constituencies', 'members')
    end

    # Allow lookups - but ensure they are SECOND in the routes list after /constituencies/:constituency_id
    lookupable('constituencies#lookup_by_letters')
  end

  ## Contact Points ##
  # /contact-points  (multiple 'contact_points' scope)
  scope '/contact-points', as: 'contact_points' do
    get '/', to: 'contact_points#index'
  end

  # /contact-points (single 'contact_point' scope)
  scope '/contact-points', as: 'contact_point' do
    # /contact-points/:contact_point_id
    scope '/:contact_point_id' do
      get '/', to: 'contact_points#show', contact_point_id: id_format_regex
    end
  end

  ## Houses ##
  # /houses (multiple 'houses' scope)
  scope '/houses', as: 'houses' do
    build_default_routes('houses', current: false, postcode: false)
  end

  # /houses (single 'house' scope)
  scope '/houses', as: 'house' do
    # /houses/:house_id
    scope '/:house_id' do
      get '/', to: 'houses#show', house_id: id_format_regex

      # /houses/:house_id/members
      build_members_routes('houses', current: true)

      # /houses/:house_id/parties
      scope '/parties', as: 'parties' do
        get '/', to: 'houses#parties'
        get '/current', to: 'houses#current_parties'

        # /houses/:house_id/parties/:party_id
        scope '/:party_id', as: 'party' do
          get '/', to: 'houses#party'

          # /houses/:house_id/parties/:party_id/members
          scope '/members', as: 'members' do
            get '/', to: 'houses#party_members'

            listable('houses#a_to_z_party_members', 'houses#party_members_letters')

            # /houses/:house_id/parties/:party_id/members/current
            scope '/current', as: 'current' do
              get '/', to: 'houses#current_party_members'

              listable('houses#a_to_z_current_party_members', 'houses#current_party_members_letters')
            end
          end
        end
      end
    end

    # Allow lookups - but ensure they are SECOND in the routes list after /houses/:house_id
    lookupable('houses#lookup_by_letters')
  end

  ### Parliaments ###
  # /parliaments (multiple 'parliaments' scope)
  scope '/parliaments', as: 'parliaments' do
    build_default_routes('parliaments', postcode: false)
    get '/previous', to: 'parliaments#previous'
    get '/next', to: 'parliaments#next'
  end

  # /parliaments (single 'parliament' scope)
  scope '/parliaments', as: 'parliament' do
    # /parliaments/:parliament_id
    scope '/:parliaments_id' do
      get '/', to: 'parliaments#show', parliament_id: id_format_regex

      build_members_routes('parliaments', current: false) do
        scope '/houses', as: 'houses' do
          # /parliaments/:parliament_id/houses
          get '/', to: 'houses#index'

          scope '/:house_id', as: 'house' do
            # /parliaments/:parliament_id/houses/:house_id
            get '/', to: 'house#show', house_id: id_format_regex
          end

          scope '/:house_id', as: 'house' do
            listable('houses#a_to_z_members', 'houses#members_letters')
          end
        end
      end

      scope '/parties', as: 'parties' do
        # parliaments/:parliament_id/parties
        get '/', to: 'parties#index'

        scope '/houses', as: 'houses' do
          # parliaments/:parliament_id/parties/houses
          get '/', to: 'houses#index'

          scope '/:house_id', as: 'house' do
            # parliaments/:parliament_id/parties/houses/:house_id
            get '/', to: 'house#show', house_id: id_format_regex
          end
        end
      end

      scope '/constituencies', as: 'constituencies' do
        # parliaments/:parliament_id/constituencies
        get '/', to: 'constituencies#index'

        listable('constituencies#a_to_z_members', 'constituencies#members_letters')
      end
    end
  end

  ## Meta ##
  # /meta
  scope '/meta', as: 'meta' do
    get '/', to: 'meta#index'
    get '/cookie-policy', to: 'meta#cookie_policy'
  end
end
