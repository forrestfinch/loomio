import BaseRecordsInterface from '@/shared/record_store/base_records_interface'
import UserModel            from '@/shared/models/user_model'
import AnonymousUserModel   from '@/shared/models/anonymous_user_model'
import {map, includes, merge, pickBy, identity} from 'lodash'

export default class UserRecordsInterface extends BaseRecordsInterface
  model: UserModel
  apiEndPoint: 'profile'

  nullModel: -> new AnonymousUserModel()

  fetchTimeZones: ->
    @remote.fetch path: "time_zones"

  fetchGroups: ->
    @fetch
      path: "groups"
      params:
        exclude_types: 'user'

  fetchMentionable: (q, model) =>
    model = model.discussion() if !model.id? && model.discussionId
    model = model.group() if !model.id? && !model.discussionId
    @fetch
      path: 'mentionable_users'
      params:
        q: q
        "#{model.constructor.singular}_id": model.id

  updateProfile: (user) =>
    user.processing = true
    @remote.post('update_profile', merge(user.serialize(), {unsubscribe_token: user.unsubscribeToken }))
    .catch (data) =>
      user.setErrors(data.errors) if data.errors
      throw data
    .finally -> user.processing = false

  uploadAvatar: (file) =>
    @remote.upload 'upload_avatar', file

  changePassword: (user) =>
    user.processing = true
    @remote.post('change_password', user.serialize()).finally ->
      user.processing = false

  destroy: => @remote.delete '/'

  saveExperience: (name, value = true) =>
    @remote.post('save_experience', experience: name, value: value)

  emailStatus: (email, token) ->
    @fetch
      path: 'email_status'
      params: pickBy({email: email, token: token}, identity)

  checkEmailExistence: (email) ->
    @fetch
      path: 'email_exists'
      params:
        email: email

  sendMergeVerificationEmail: (targetEmail) ->
    @fetch
      path: 'send_merge_verification_email'
      params:
        target_email: targetEmail
