defmodule TurboOctoPancakes.FakeMailer do
  def send_emails(recipients) when is_list(recipients) do
    # volontary not optimized
    count = length(recipients)
    IO.puts("FakeMailer: starting to send #{count} emails")

    Enum.each(recipients, fn %{name: _name} ->
      Process.sleep(:rand.uniform(50))
    end)

    IO.puts("FakeMailer: finished sending #{count} emails")
    :ok
  end
end
