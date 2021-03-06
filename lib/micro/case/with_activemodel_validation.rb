# frozen_string_literal: true

require 'kind/validator'

require 'micro/case'

module Micro
  class Case
    include Micro::Attributes::Features::ActiveModelValidations

    def self.auto_validation_disabled?
      return @disable_auto_validation if defined?(@disable_auto_validation)
    end

    def self.disable_auto_validation
      @disable_auto_validation = true
    end

    private

      def __call_use_case
        return failure_by_validation_error(self) if !self.class.auto_validation_disabled? && errors.present?

        result = call!

        return result if result.is_a?(Result)

        raise Error::UnexpectedResult.new("#{self.class.name}#call!")
      end

      def failure_by_validation_error(object)
        errors = object.respond_to?(:errors) ? object.errors : object

        Failure Micro::Case::Config.instance.activemodel_validation_errors_failure, result: {
          errors: errors
        }
      end
  end
end
