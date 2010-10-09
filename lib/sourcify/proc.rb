module Sourcify

  class MultipleMatchingProcsPerLineError < Exception; end
  class NoMatchingProcError < Exception; end
  class ParserInternalError < Exception; end
  class CannotParseEvalCodeError < Exception; end
  class CannotHandleCreatedOnTheFlyProcError < Exception; end

  module Proc
    def self.included(base)
      base.class_eval do

        ref_proc = lambda {}

        # == Proc#source_location

        unless ref_proc.respond_to?(:source_location)

          # Added as a bonus, by default, only 1.9.* implements this.
          def source_location
            unless created_on_the_fly?
              @source_location ||= (
                file, line = /^#<Proc:0x[0-9A-Fa-f]+@(.+):(\d+).*?>$/.match(inspect)[1..2]
                [file, line.to_i]
              )
            end
          end

          # HACK to make it easy to determine if a proc is created on the fly
          ::Proc.class_eval do
            attr_writer :created_on_the_fly
            def created_on_the_fly?
              !!@created_on_the_fly
            end
          end

          [::Method, ::Symbol].each do |klass|
            begin
              klass.class_eval do
                alias_method :__pre_sourcified_to_proc, :to_proc
                def to_proc
                  (_proc = __pre_sourcified_to_proc).created_on_the_fly = true
                  _proc
                end
              end
            rescue NameError
            end
          end

        end

        # == Proc#to_source

        if ref_proc.respond_to?(:to_ruby)

          def to_source(opts = {})
            to_ruby
          end

        else

          def to_source(opts = {})
            Sourcify.require_rb('proc', 'parser')
            (@parser ||= Parser.new(self, opts)).source
          end

        end

        # == Proc#to_sexp

        if ref_proc.respond_to?(:to_sexp)

          alias_method :__pre_sourcify_to_sexp, :to_sexp

          def to_sexp(opts = {})
            __pre_sourcify_to_sexp
          end

        else
          def to_sexp(opts = {})
            Sourcify.require_rb('proc', 'parser')
            (@parser ||= Parser.new(self, opts)).sexp
          end
        end

      end
    end
  end

end

::Proc.class_eval do
  include Sourcify::Proc
end
