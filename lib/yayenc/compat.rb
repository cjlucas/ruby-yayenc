class Range
  # Range#size wasn't added until 2.0
  unless respond_to? :size
    define_method(:size) do
      size = self.end - self.begin
      exclude_end? ? size : size + 1
    end
  end
end
