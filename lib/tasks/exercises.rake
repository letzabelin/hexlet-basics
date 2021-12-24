# frozen_string_literal: true

namespace :exercises do
  desc 'Load exercies'
  task :load, [:lang] => :environment do |_task, args|
    language_version = LanguageVersionManager.new.find_or_create_language_with_version(args.lang)

    ExerciseLoader.new.run(language_version)
  end

  desc 'Remove exercies'
  task remove: :environment do
    docker_exercise_api = ApplicationContainer['docker_exercise_api']

    languages = Language.all

    languages.each do |language|
      latest_versions = language.versions
                                .reverse_order
                                .take(10)

      latest_versions.delete(language.current_version)

      latest_versions.each do |version|
        docker_exercise_api.remove_image(language.slug, version.image_tag)
      end
    end
  end
end
