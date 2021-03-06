###
# Copyright (C) 2014-2015 Taiga Agile LLC <taiga@taiga.io>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: history.controller.coffee
###

module = angular.module("taigaHistory")

class HistorySectionController
    @.$inject = [
        "$tgResources",
        "$tgRepo",
        "$tgStorage",
    ]

    constructor: (@rs, @repo, @storage) ->
        @.viewComments = true
        @._loadHistory()
        @.reverse = @storage.get("orderComments")

    _loadHistory: () ->
        @rs.history.get(@.name, @.id).then (history) =>
            @._getComments(history)
            @._getActivities(history)

    _getComments: (comments) ->
        @.comments = _.filter(comments, (item) -> item.comment != "")
        if @.reverse
            @.comments - _.reverse(@.comments)
        @.commentsNum = @.comments.length

    _getActivities: (activities) ->
        @.activities =  _.filter(activities, (item) -> Object.keys(item.values_diff).length > 0)
        @.activitiesNum = @.activities.length

    onActiveHistoryTab: (active) ->
        @.viewComments = active

    deleteComment: (commentId) ->
        type = @.name
        objectId = @.id
        activityId = commentId
        @.deleting = true
        return @rs.history.deleteComment(type, objectId, activityId).then =>
            @._loadHistory()
            @.deleting = false

    editComment: (commentId, comment) ->
        type = @.name
        objectId = @.id
        activityId = commentId
        @.editing = true
        return @rs.history.editComment(type, objectId, activityId, comment).then =>
            @._loadHistory()
            @.editing = false

    restoreDeletedComment: (commentId) ->
        type = @.name
        objectId = @.id
        activityId = commentId
        @.editing = true
        return @rs.history.undeleteComment(type, objectId, activityId).then =>
            @._loadHistory()
            @.editing = false

    addComment: () ->
        type = @.type
        @.loading = true
        @repo.save(@.type).then =>
            @._loadHistory()
            @.loading = false

    onOrderComments: () ->
        @.reverse = !@.reverse
        @storage.set("orderComments", @.reverse)
        @._loadHistory()

module.controller("HistorySection", HistorySectionController)
