# frozen_string_literal: true

class Api::Lessons::ChecksController < Api::Lessons::ApplicationController
  def create
    lesson_version = resource_lesson.versions.find(params[:data][:attributes][:version_id])
    code = params[:data][:attributes][:code]

    if resource_lesson.outdated?(lesson_version)
      return render json: {
        message: 'lesson version is outdated or deleted'
      }, status: :gone
    end

    language_version = lesson_version.language_version
    lesson_exercise_data = LessonTester.run(lesson_version, language_version, code, current_user)

    if lesson_exercise_data[:passed]
      lesson_member = resource_lesson.members.find_by!(user: current_user)
      lesson_member.finish!
    end

    render json: {
      attributes: lesson_exercise_data
    }, status: :ok
  end
end
