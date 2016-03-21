describe "Schedulör", ->
  it "can be required", ->
    assert.truthy require "schedulor"

  it "lets you access submodules", ->
    schedulor = require "schedulor"

    assert.equal require("schedulor.schedule"), schedulor.schedule
    assert.equal require("schedulor.curve"),    schedulor.curve

  it "doesn't error when you try to access non-exitant modules", ->
    schedulor = require "schedulor"

    local mod
    assert.has_no.errors ->
      mod = schedulor.not_a_module

    assert.is_nil mod
