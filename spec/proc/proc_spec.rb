require File.expand_path('../spec_helper', __FILE__)

def m(*args, &block)
  block
end

describe Sourcify::Proc do
  describe 'with proc' do
    extend Sourcify::SpecHelper

    def process(args)
      block, matcher = args

      if matcher
        block.to_source(&matcher)
      else
        block.to_source
      end
    end

    example(%%
    ## wrt attache, having explicit recipient for method
    ##
    #" proc do
    #"   :thing
    #" end
    %,(
      b = Proc.new do
        :thing
      end
    ))

    example(%%
    ## wrt attache, having implicit recipient for method
    ##
    #" proc do
    #"   :thing
    #" end
    %,(
      b = proc do
        :thing
      end
    ))

    example(%%
    ## wrt block args, having no arg
    ##
    #" proc do
    #"   :thing
    #" end
    %,(
      b = proc do
        :thing
      end
    ))

    example(%%
    ## wrt block args, having 1 arg
    ##
    #" proc do |x|
    #"   :thing
    #" end
    %,(
      b = proc do |x|
        :thing
      end
    ))

    example(%%
    ## wrt block args, having multiple args
    ##
    #" proc do |x, y, z|
    #"   :thing
    #" end
    %,(
      b = proc do |x, y, z|
        :thing
      end
    ))

    example(%%
    ## wrt block args, having only splat args
    ##
    #" proc do |*x|
    #"   :thing
    #" end
    %,(
      b = proc do |*x|
        :thing
      end
    ))

    example(%%
    ## wrt block args, having multiple & splat args
    ##
    #" proc do |x, y, *z|
    #"   :thing
    #" end
    %,(
      b = proc do |x, y, *z|
        :thing
      end
    ))

    example(%%
    ## wrt block type, as do-block
    ##
    #" proc do
    #"   :thing
    #" end
    %,(
      b = proc do
        :thing
      end
    ))

    example(%%
    ## wrt block type, as brace-block
    ##
    #" proc {
    #"   :thing
    #" }
    %,(
      b = proc {
        :thing
      }
    ))

    example(%%
    ## wrt multiple matches, having unique parameters (1)
    ##
    #" proc do |x| proc {|y| :this }
    #"   :that
    #" end
    %,(
      b = proc do |x| proc {|y| :this }
        :that
      end
    ))

    example(%%
    ## wrt multiple matches, having unique parameters (2)
    ##
    #" proc { |x| proc do |y| :this end
    #"   :that
    #" }
    %,(
      b = proc { |x| proc do |y| :this end
        :that
      }
    ))

    example(%%
    ## wrt multiple matches, having unique parameters (3)
    ##
    #" proc {|y| :that }
    %,(
      b = (proc do |x| :this end; proc {|y| :that })
    ))

    example(%%
    ## wrt multiple matches, having unique parameters (4)
    ##
    #" proc do |y| :that end
    %,(
      b = (proc { |x| :this }; proc do |y| :that end)
    ))

    example(%%
    ## wrt multiple matches, having non-unique parameters (1)
    ##
    #! Sourcify::MultipleMatchingProcsPerLineError
    %,(
      b = proc do |x| proc {|x| :this }
        :that
      end
    ))

    example(%%
    ## wrt multiple matches, having non-unique parameters (2)
    ##
    #! Sourcify::MultipleMatchingProcsPerLineError
    %,(
      b = proc { |x| proc do |x| :this end
        :that
      }
    ))

    example(%%
    ## wrt multiple matches, having non-unique parameters (3)
    ##
    #! Sourcify::MultipleMatchingProcsPerLineError
    %,(
      b = (proc do |x| :this end; proc {|x| :that })
    ))

    example(%%
    ## wrt multiple matches, having non-unique parameters (4)
    ##
    #! Sourcify::MultipleMatchingProcsPerLineError
    %,(
      b = (proc { |x| :this }; proc do |x| :that end)
    ))

    example(%%
    ## wrt multiple matches, having matcher w specified #index (1)
    ##
    #" proc { |x| :this }
    %,([
      (proc { |x| :this }; proc { |x| :that }), # block
      proc { |match| match.index == 0 }         # matcher
    ]))

    example(%%
    ## wrt multiple matches, having matcher w specified #index (2)
    ##
    #" proc { |x| :that }
    %,[
      (proc { |x| :this }; proc { |x| :that }), # block
      proc { |match| match.index == 1 }         # matcher
    ])

    example(%%
    ## wrt multiple matches, having matcher w specified #first?
    ##
    #" proc { |x| :this }
    %,[
      (proc { |x| :this }; proc { |x| :that }), # block
      proc { |match| match.first? }             # matcher
    ])

    example(%%
    ## wrt multiple matches, having matcher w specified #last?
    ##
    #" proc { |x| :that }
    %,[
      (proc { |x| :this }; proc { |x| :that }), # block
      proc { |match| match.last? }              # matcher
    ])

    example(%%
    ## wrt multiple matches, having matcher w specified #body (1)
    ##
    #" proc { |x| :this }
    %,[
       (proc { |x| :this }; proc { |x| :that }), # block
       proc { |match| match.body =~ /:this/ }    # matcher
    ])

    example(%%
    ## wrt multiple matches, having matcher w specified #body (2)
    ##
    #" proc { |x| :that }
    %,[
      (proc { |x| :this }; proc { |x| :that }), # block
      proc { |match| match.body =~ /:that/ }    # matcher
    ])

    example(%%
    ## wrt positioning, attache & block on the same line
    ##
    #" proc do
    #"   :thing
    #" end
    %,(
      b = m do
        :thing
      end
    ))

    example(%%
    ## wrt positioning, attache & block on the different lines (1)
    ##
    #" proc do
    #"   :thing
    #" end
    %,(
      b = m \
        do
          :thing
        end
    ))

    example(%%
    ## wrt positioning, attache & block on the different lines (2)
    ##
    #" proc do
    #"   :thing
    #" end
    %,(
      b = m(
        :arg
      ) do
          :thing
        end
    ))

    example(%%
    ## wrt positioning, attache & block on the different lines (3)
    ##
    #" proc do
    #"   :thing
    #" end
    %,(
      b = m \
        :arg do
          :thing
        end
    ))

    example(%%
    ## wrt positioning, attache & block on the different lines (4)
    ##
    #" proc do
    #"   :thing
    #" end
    %,(
      b = m \
        :arg \
        do
          :thing
        end
    ))

    example(%%
    ## wrt preceding hash, having no items (1)
    ##
    #" proc do
    #"   :thing
    #" end
    %,(
      b = m({}) do
        :thing
      end
    ))

    example(%%
    ## wrt preceding hash, having no items (2)
    ##
    #" proc { :thing }
    %,(
      b = m({}) { :thing }
    ))

    example(%%
    ## wrt preceding hash, having no items (3)
    ##
    #" proc { }
    %,(
      b = m({}) { }
    ))

    example(%%
    ## wrt preceding hash, having items (1)
    ##
    #" proc do
    #"   :thing
    #" end
    %,(
      b = m({:a => 1, :b => 2}) do
        :thing
      end
    ))

    example(%%
    ## wrt preceding hash, having items (2)
    ##
    #" proc { :thing }
    %,(
      b = m({:a => 1, :b => 2}) { :thing }
    ))

  end
end
