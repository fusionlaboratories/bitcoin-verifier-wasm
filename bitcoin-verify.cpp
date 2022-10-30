#include <iostream>

#include <chainparams.h>
#include <primitives/block.h>
#include <streams.h>
#include <validation.h>

int main () {
  CBlock block;
  std::vector<unsigned char> bytes(
      (std::istreambuf_iterator<char>(std::cin))
    , std::istreambuf_iterator<char>()
  );
  CDataStream stream(bytes, SER_NETWORK, PROTOCOL_VERSION);
  stream >> block;

  BlockValidationState validationState;
  const auto chainParams = CreateMainChainParams();
  if (CheckBlock(block, validationState, chainParams->GetConsensus(), true, true)) {
    return 0;
  } else {
    return 1;
  }
}
