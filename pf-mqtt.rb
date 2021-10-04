#!/usr/bin/env ruby

require 'dotenv/load'
require 'mqtt'
require 'xmlrpc/client'

Dotenv.require_keys('MQTT_USERNAME', 'MQTT_PASSWORD', 'MQTT_HOST', 'MQTT_PRONTERFACE_STATUS_TOPIC')
updatePeriod = ENV['MQTT_PRONTERFACE_UPDATE_PERIOD'] || 3
pfPort = ENV['PRONTERFACE_RPC_PORT'] || 7978

mqtt = MQTT::Client.connect("mqtt://#{ENV['MQTT_USERNAME']}:#{ENV['MQTT_PASSWORD']}@#{ENV['MQTT_HOST']}")
XMLRPC::Config.module_eval { remove_const(:ENABLE_NIL_PARSER) }
XMLRPC::Config.const_set(:ENABLE_NIL_PARSER, true)
pronterface = XMLRPC::Client.new2("http://localhost:#{pfPort}/")

loop do
  pfStatus = pronterface.call('status')
  mqtt.publish(ENV['MQTT_PRONTERFACE_STATUS_TOPIC'], pfStatus['temps']['T'][0])
  sleep updatePeriod
end
