#include <iostream>

#include <chainparams.h>
#include <primitives/block.h>
#include <streams.h>
#include <validation.h>

#include "header.h"

int main () {
  CBlockHeader header;
  SpanReader stream = SpanReader(SER_NETWORK, PROTOCOL_VERSION, header_bytes);
  stream >> header;
  BlockValidationState validationState;
  const auto chainParams = CreateMainChainParams();

  if (CheckBlockHeader(header, validationState, chainParams->GetConsensus(), true)) {
    return 0;
  } else {
    return 1;
  }
}
