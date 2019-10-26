# -*- encoding: utf-8 -*-

# @author: M. Sakano (Wise Babel Ltd)

require 'plain_text'
require 'open3'

$stdout.sync=true
$stderr.sync=true
# print '$LOAD_PATH=';p $LOAD_PATH

#################################################
# Unit Test
#################################################

gem "minitest"
# require 'minitest/unit'
require 'minitest/autorun'

class TestUnitRubyUnicodeProp < MiniTest::Test
  T = true
  F = false
  SCFNAME = File.basename(__FILE__)
  EXE = "%s/../bin/%s" % [File.dirname(__FILE__), File.basename(__FILE__).sub(/^test_(.+)\.rb/, '\1')]

  def setup
  end

  def teardown
  end

  def test_ruby_unicode_prop01
    o, e, s = Open3.capture3 EXE+" ASCII"
    assert_equal 0, s.exitstatus
    assert_match(/\A0000 .\n0001 .\n.*\n004A J/m, o)
    assert_operator 70, '<', o.count($/)
    assert_empty e
    size_ascii = o.size

    o, e, s = Open3.capture3 EXE+" -l ASCII"
    assert_equal 0, s.exitstatus
    assert_match(/\A0000 .\n0001 .\n.*\n004a J/m, o)

    o, e, s = Open3.capture3 EXE+" ascii"
    assert_equal 0, s.exitstatus
    assert_match(/\A0000 .\n0001 .\n.*\n004A J/m, o)
    assert_operator 70, '<', o.count($/)
    assert_empty e

    o, e, s = Open3.capture3 EXE+" -p ASCII" # => Error (b/c "ascii" in the POSIX form)
    assert_equal 1, s.exitstatus
    assert_match(/invalid POSIX/i, e)

    o, e, s = Open3.capture3 EXE+" -d H ASCII"
    assert_equal 0, s.exitstatus
    assert_match(/\A0000H.\n0001H.\n.*\n004AHJ/m, o)
    o, e, s = Open3.capture3 EXE+" --delimiter=H ASCII"
    assert_match(/\A0000H.\n0001H.\n.*\n004AHJ/m, o)

    o, e, s = Open3.capture3 EXE+" --without-codepoint ASCII"  # characters only (-c)
    assert_equal 0, s.exitstatus
    assert_equal 0, o[40..-1].chomp.count($/) # "\n" is included in ASCII itself.
    assert_equal 1, o.count(" ")
    assert_match(/XYZ/m, o)
    assert_empty e

    o, e, s = Open3.capture3 EXE+" -c -d H ASCII"  # characters only (-c)
    assert_equal 0, o[40..-1].chomp.count($/) # "\n" is included in ASCII itself.
    assert_equal 1, o.count(" ")
    assert_match(/XHYHZ/m, o)
    assert_empty e
    
    o, e, s = Open3.capture3 EXE+" -c -d NL ASCII"  # characters only (-c)
    assert_operator 70, '<', o.count($/), "Special case of 'NL' is not handled correctly."
    assert_equal 1, o.count(" ")
    assert_match(/X\nY\nZ/m, o)
    assert_empty e
    
    o, e, s = Open3.capture3 EXE+" --without-char ASCII"  # codepoints only (-n)
    assert_equal 0, o.count(" ")
    assert_equal 0, o.count("X")
    assert_operator 70, '<', o.count($/)
    assert_equal "0000\n0001\n", o[0..9]
    assert_empty e

    o, e, s = Open3.capture3 EXE+" -n -d H ASCII"  # codepoints only (-n)
    assert_equal 0, o[60..-1].chomp.count($/) # "\n" is included in ASCII itself.
    assert_operator 70, '<', o.count(?H)
    assert_equal "0000H0001H", o[0..9]
    assert_match(/\A0000H0001H.*H004AH/m, o)
    assert_empty e

    o, e, s = Open3.capture3 EXE+" -l -n -d H ASCII"  # codepoints only (-n)
    assert_match(/\A0000H0001H.*H004aH/m, o)

    # Multiple arguments
    o, e, s = Open3.capture3 EXE+" Currency_Symbol ASCII"
    assert_equal 0, s.exitstatus
    assert_match(/0023 \#\n0024 \$\n.*00A3 £/m, o)
    assert_operator size_ascii, '<', o.size  # Increased size (because Currency Symbols are added!)

    o, e, s = Open3.capture3 EXE+" ASCII Digit"
    ou_ad = o
    si_ad = o.size
    o, e, s = Open3.capture3 EXE+" Digit ASCII"
    ou_da = o
    o, e, s = Open3.capture3 EXE+" Digit"
    size_digit  = o.size

    assert_equal    ou_ad, ou_da, 'Should be unordered for multiple arguments.'
    assert_operator si_ad, '<', size_ascii + size_digit, 'Duplication should not appear.'
  end


  ## tests of Errors ##
  def test_ruby_unicode_prop_error02
    o, e, s = Open3.capture3 EXE+" ASCII -d" # => Error (-d without a parameter)
    assert_equal 1, s.exitstatus
    assert_empty o

    o, e, s = Open3.capture3 EXE+" -n -c ASCII" # => Error
    assert_equal 1, s.exitstatus
    assert_empty o
    assert_match(/specify/m, e)

    o, e, s = Open3.capture3 EXE+" -Z ASCII" # => Error
    assert_equal 1, s.exitstatus
    assert_match(/(invalid|ambiguous) option/i, e)

    o, e, s = Open3.capture3 EXE+" naiyo" # => Error
    assert_equal 1, s.exitstatus
    assert_empty o
    assert_match(/RegexpError/m, e)

    o, e, s = Open3.capture3 EXE  # => Error (No arguments specified)
    assert_equal 1, s.exitstatus
    assert_empty o
  end
end # class TestUnitRubyUnicodeProp < MiniTest::Test

