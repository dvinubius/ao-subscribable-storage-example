local json = require "json"

-- LOAD SUBSCRIBABLE CAPABILITIES

if not Subscribable then
  Subscribable = require 'subscribable' ({
    initial = true,
    useDB = false
  })
  Subscribable.PAYMENT_TOKEN = "PaymentToken_Process_Id"
  Subscribable.PAYMENT_TOKEN_TICKER = "PaymentToken_Ticker"
else
  Subscribable = require 'subscribable' ({
    initial = false,
    existing = Subscribable
  })
end

--[[
  most simple implementation
    -> subscribers can only receice ALL ticker prices
    -> configure no checkFn and payloadFn, because
        - the logic for when to dispatch is straightforward
        - the payload is readily available when it's time to dispatch
 ]]
Subscribable.configTopicsAndChecks({
  ['prices-update'] = {
    description = 'Update on prices',
    returns = '{ [ticker: string] : string }', -- optionally describe payload format
  },
})

-- CORE STORAGE PROCESS

if not Storage then Storage = {} end

Handlers.add(
  "Store-Prices",
  Handlers.utils.hasMatchingTag("Action", "Store-Prices"),
  function(msg)
    assert(msg.Owner == 'jnioZFibZSCcV8o-HkBXYPYEYNib4tqfexP0kCBXX_M', 'Only trusted address allowed to store price')
    local priceData = json.decode(msg.Data)
    table.insert(Storage, priceData)
    -- The only place where subscribers are notified
    Subscribable.notifyTopic('prices-update', priceData, msg.Timestamp)
  end
)

-- Handlers.add("Request-Latest-Data", ...)
