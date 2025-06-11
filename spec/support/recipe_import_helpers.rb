module RecipeImportHelpers
  def mock_site!(data, other_data = nil)
    template = <<-ERB
    <html>
      <head>
        <script type="application/ld+json">
          <%= data.respond_to?(:to_json) ? data.to_json : data  %>
        </script>
        <% if other_data %>
        <script type="application/ld+json">
          <%= other_data.respond_to?(:to_json) ? other_data.to_json : other_data  %>
        </script>
        <% end %>
      </head>
      <body>boo</body>
    </html>
    ERB

    html = ERB.new(template).result(binding)
    allow(URI).to receive(:open) { double(read: html) }
  end
end
