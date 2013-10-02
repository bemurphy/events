You probably don't want to use this.

This is just me experimenting with different fanout
patterns, RabbitMQ, redis, and the ActiveSupport::Notfication::Fanout
bus.

The basic idea at play here is that, in any given Rails/Ruby web app,
you will end up with interesting events that you want to trigger
tangential concerns.  Classic examples are, sending a campfire
notification on a new sale, or sending an email to billing when
a user cancels.  These tend to end up layering on your core concerns
of the app and muddying around the code that actually matters the most.

the idea is to publish events from within models/services that can
be subscribed to, with keys like 'account.created', and then have
a single subscriber that proxies those requests into RabbitMQ using
the key as a routing key.  That can then fanout to multiple notifiers
and event handlers, and decouple your main code from behavior (and
exceptions that could occur) in less important event tracking.
