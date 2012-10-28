module Pod
  class Podfile

    # The {TargetDefinition} stores the information of a CocoaPods static
    # library. The target definition can be linked with one or more targets of
    # the user project.
    #
    # Target definitions can be nested and by default inherit the dependencies
    # of the parent.
    #
    class TargetDefinition

      # @return [String, Symbol] the name of the target definition.
      #
      attr_reader :name

      # @return [TargetDefinition] the parent target definition.
      #
      attr_reader :parent

      # @param  [String, Symbol]
      #         name @see name
      #
      # @param  [TargetDefinition] parent
      #         @see parent
      #
      # @option options [Bool] :exclusive
      #         @see exclusive?
      #
      def initialize(name, parent, options = {})
        @name      = name
        @parent    = parent
        @exclusive = options[:exclusive]
        @target_dependencies = []
      end

      # @return [Array] the list of the dependencies of the target definition,
      #         excluding inherited ones.
      #
      attr_reader :target_dependencies

      # @return [Bool] whether the target definition has at least one
      #         dependency, excluding inherited ones.
      #
      def empty?
        target_dependencies.empty?
      end

      # @return [Array<Dependency>] the list of the dependencies of the target
      #         definition including the inherited ones.
      #
      def dependencies
        @target_dependencies + (exclusive? ? [] : @parent.dependencies)
      end

      # Sets if the target definition is exclusive.
      #
      attr_writer :exclusive

      # @return [Bool] whether the target definition should inherit the
      #         dependencies of the parent.
      #
      # @note   A target is automatically `exclusive` if the `platform` does
      #         not match the parent's `platform`.
      #
      def exclusive?
        @exclusive || ( @platform && @parent.platform != @platform )
      end

      # @return [Array] the list of the names of the Xcode targets with which
      #         this target definition should be linked with.
      #
      attr_accessor :link_with

      # Sets the {Platform} of the target definition.
      #
      attr_writer :platform

      # @return [Platform] the platform of the target definition.
      #
      def platform
        @platform || (@parent.platform if @parent)
      end

      # Sets whether the target definition should inhibit the warnings during
      # compilation.
      #
      attr_writer :inhibit_all_warnings

      # @return [Bool] whether the target definition should silence all the
      #         warnings with a compiler flag.
      #
      def inhibit_all_warnings?
        @inhibit_all_warnings || (@parent.inhibit_all_warnings? if @parent)
      end

      # @return [String] the label of the target definition generated by its
      #         name. Used to name the support files generated by CocoaPods
      #
      def label
        if name == :default
          "Pods"
        elsif exclusive?
          "Pods-#{name}"
        else
          "#{@parent.label}-#{name}"
        end
      end
    end
  end
end