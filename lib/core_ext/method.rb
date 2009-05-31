# Method#to_proc have issues flattens array like objects
# http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/65351
class Method
  def filter_to_proc
    case
    when arity > 0
      proc do |*args|
        (arity - args.size).times() { args << nil } if arity > args.size
        self.call(*(args[0,arity]))
      end
    when arity == 0
      proc { |*args| self.call }
    when arity < 0
      rarity = -1 - arity
      proc do |*args|
        (rarity - args.size).times() { args << nil } if rarity > args.size
        self.call(*args)
      end
    end
  end
end