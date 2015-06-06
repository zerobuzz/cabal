module UnitTests.Distribution.Client.GZipUtils (
  tests
  ) where

import Codec.Compression.GZip          as GZip
import Codec.Compression.Zlib          as Zlib
import Control.Exception.Base                  (evaluate)
import Control.Exception                       (try, SomeException)
import Control.Monad                           (void)
import Data.ByteString.Lazy.Char8     as BS    (pack, init, length)
import Data.Either                             (isLeft)
import Data.Monoid                             ((<>))
import Distribution.Client.GZipUtils           (maybeDecompress)

import Test.Tasty
import Test.Tasty.HUnit

tests :: [TestTree]
tests = [ testCase "maybeDecompress" maybeDecompressUnitTest
        ]

maybeDecompressUnitTest :: Assertion
maybeDecompressUnitTest =
        assertBool "decompress plain" (maybeDecompress original       == original)
     >> assertBool "decompress zlib"  (maybeDecompress compressedZlib == original)
     >> assertBool "decompress gzip"  (maybeDecompress compressedGZip == original)
     >> (runBrokenStream >>= assertBool "decompress broken" . isLeft)
  where
    original = BS.pack "original uncompressed input"
    compressedZlib = Zlib.compress original
    compressedGZip = GZip.compress original

    runBrokenStream :: IO (Either SomeException ())
    runBrokenStream = try . void . evaluate . BS.length $ maybeDecompress (BS.init compressedZlib <> BS.pack "*")
