# Audit-trial-with-mongodb

Ruby module for log all db changes to mongoDB database. Easly turn on any model with audit trial with help of this module

Usage Example:
```ruby
class User < ActiveRecord::Base
  include Auditable
  ...
end
```
