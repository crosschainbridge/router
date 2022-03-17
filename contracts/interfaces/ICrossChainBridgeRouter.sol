// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

interface ICrossChainBridgeRouter {
  // addresses of other ccb-related contracts
  function bridgeChef() external returns (address);

  function bridgeERC20() external returns (address);

  function liquidityManager() external returns (address);

  function bridgeERC721() external returns (address);

  function liquidityMiningPools() external returns (address);

  function rewardPools() external returns (address);

  // ###################################################################################################################
  // ********************************************** BRIDGE ERC20 *******************************************************
  // ###################################################################################################################
  // ------------------------------------------------- DEPOSIT  --------------------------------------------------------

  /**
   * @notice Accepts ERC20 token deposits that should be bridged into another network
   * (effectively starting a new bridge transaction)
   *
   * @param token the ERC20 contract the to-be-bridged token was issued with
   * @param amount the amount that is being deposited
   * @param receiverAddress target address the bridged token should be sent to (in the target network)
   * @param targetChainId chain ID of the target network
   *
   * @dev emits event TokensDeposited after successful deposit
   */
  function depositERC20TokensToBridge(
    IERC20 token,
    uint256 amount,
    address receiverAddress,
    uint256 targetChainId
  ) external payable;

  /**
   * @notice Accepts native token deposits that should be bridged into another network
   * (effectively starting a new bridge transaction)
   *
   * @param amount the amount that is being deposited
   * @param receiverAddress target address the bridged token should be sent to (in the target network)
   * @param targetChainId chain ID of the target network
   * @dev emits event TokensDeposited after successful deposit
   */
  function depositNativeTokensToBridge(
    uint256 amount,
    address receiverAddress,
    uint256 targetChainId
  ) external payable;

  // ------------------------------------------------- RELEASE  --------------------------------------------------------

  /**
   * @notice Releases ERC20 tokens in this network after a deposit was made in another network
   *         (effectively completing a bridge transaction)
   *
   * @param sigV Array of recovery Ids for the signature
   * @param sigR Array of R values of the signatures
   * @param sigS Array of S values of the signatures
   * @param receiverAddress The account to receive the tokens
   * @param sourceNetworkTokenAddress the address of the ERC20 contract in the network the deposit was made
   * @param amount The amount of tokens to be released
   * @param depositChainId chain ID of the network in which the deposit was made
   * @param depositNumber The identifier of the corresponding deposit
   * @dev emits event TokensReleased after successful release
   */
  function releaseERC20TokenBridgeDeposit(
    uint8[] memory sigV,
    bytes32[] memory sigR,
    bytes32[] memory sigS,
    address receiverAddress,
    address sourceNetworkTokenAddress,
    uint256 amount,
    uint256 depositChainId,
    uint256 depositNumber
  ) external payable;

  /**
   * @notice Releases native tokens in this network that were deposited in another network
   *         (effectively completing a bridge transaction)
   *
   * @param sigV Array of recovery Ids for the signature
   * @param sigR Array of R values of the signatures
   * @param sigS Array of S values of the signatures
   * @param receiverAddress The account to receive the tokens
   * @param sourceNetworkTokenAddress the address of the ERC20 contract in the network the deposit was made
   * @param amount The amount of tokens to be released
   * @param depositChainId chain ID of the network in which the deposit was made
   * @param depositNumber The identifier of the corresponding deposit
   * @dev emits event TokensReleased after successful release
   */
  function releaseNativeTokenBridgeDeposit(
    uint8[] memory sigV,
    bytes32[] memory sigR,
    bytes32[] memory sigS,
    address receiverAddress,
    address sourceNetworkTokenAddress,
    uint256 amount,
    uint256 depositChainId,
    uint256 depositNumber
  ) external payable;

  // ------------------------------------------ GET BRIDGE FEE QUOTE ---------------------------------------------------

  /**
   * @notice Returns the estimated bridge fee for a specific ERC20 token and bridge amount
   *
   * @param tokenAddress the address of the token that should be bridged
   * @param amountToBeBridged the amount to be bridged
   * @return bridgeFee the estimated bridge fee (in to-be-bridged token)
   */
  function getERC20BridgeFeeQuote(address tokenAddress, uint256 amountToBeBridged)
    external
    view
    returns (uint256 bridgeFee);

  // ###################################################################################################################
  // ********************************************** BRIDGE ERC721 ******************************************************
  // ###################################################################################################################
  // ------------------------------------------------- DEPOSIT  --------------------------------------------------------

  /**
   * @notice Deposits an ERC721 token into the bridge (effectively starting a bridge transaction)
   *
   * @dev the collection must be whitelisted by the bridge or the call will be reverted
   *
   * @param collectionAddress the address of the ERC721 contract the collection was issued with
   * @param tokenId the (native) ID of the ERC721 token that should be bridged
   * @param receiverAddress target address the bridged token should be sent to
   * @param targetChainId chain ID of the target network
   *
   * @dev emits event TokenDeposited after successful deposit
   */
  function depositERC721TokenToBridge(
    address collectionAddress,
    uint256 tokenId,
    address receiverAddress,
    uint256 targetChainId
  ) external payable;

  // ------------------------------------------------- RELEASE  --------------------------------------------------------

  /**
   * @notice Releases an ERC721 token in this network after a deposit was made in another network
   *         (effectively completing a bridge transaction)
   *
   * @param sigV Array of recovery Ids for the signature
   * @param sigR Array of R values of the signatures
   * @param sigS Array of S values of the signatures
   * @param receiverAddress The account to receive the tokens
   * @param sourceNetworkCollectionAddress the address of the ERC721 contract in the network the deposit was made
   * @param tokenId The token id to be sent
   * @param depositChainId chain ID of the network in which the deposit was made
   * @param depositNumber The identifier of the corresponding deposit
   *
   * @dev emits event TokenReleased after successful release
   */
  function releaseERC721TokenDeposit(
    uint8[] memory sigV,
    bytes32[] memory sigR,
    bytes32[] memory sigS,
    address receiverAddress,
    address sourceNetworkCollectionAddress,
    uint256 tokenId,
    uint256 depositChainId,
    uint256 depositNumber
  ) external payable;

  // ------------------------------------------ GET BRIDGING FEE QUOTE -------------------------------------------------

  /**
   * @notice Returns the estimated fee for bridging one token of a specific ERC721 collection in native currency
   *         (e.g. ETH, BSC, MATIC, AVAX, FTM)
   *
   * @param collectionAddress the address of the collection
   * @return bridgeFee the estimated bridge fee (in network-native currency)
   */
  function getERC721BridgeFeeQuote(address collectionAddress) external view returns (uint256 bridgeFee);

  // ###################################################################################################################
  // ******************************************** MANAGE LIQUIDITY *****************************************************
  // ###################################################################################################################
  // ----------------------------------------- ADD LIQUIDITY TO BRIDGE -------------------------------------------------

  /**
   * @notice Adds ERC20 liquidity to an existing pool or creates a new one, if none exists for the provided token
   *
   * @param token the address of the token for which liquidity should be added
   * @param amount the amount of tokens to be added
   *
   * @dev emits event LiquidityPoolCreated (only if a new pool is created)
   * @dev emits event LiquidityAdded after successful deposit
   */
  function addLiquidityERC20(IERC20 token, uint256 amount) external payable;

  /**
   * @notice Adds native liquidity to an existing pool or creates a new one, if it does not exist yet
   *
   * @param amount the amount of native tokens to be added
   *
   * @dev emits event LiquidityPoolCreated (only if a new pool is created)
   * @dev emits event LiquidityAdded after successful deposit
   */
  function addLiquidityNative(uint256 amount) external payable;

  // TODO CONTINUE HERE
  // --------------------------------------- REMOVE LIQUIDITY FROM BRIDGE ----------------------------------------------
  /**
   * @notice Burns LP tokens and removes previously provided ERC20 liquidity from the bridge
   *
   * @param token the token for which liquidity should be removed from this pool
   *
   * @dev emits event LiquidityRemoved
   */
  function withdrawLiquidityERC20(IERC20 token, uint256 amount) external payable;

  /**
   * @notice Removes native (i.e. in the network-native token) liquidity from a liquidity pool
   *
   * @param amount the amount of liquidity to be removed
   *
   * @dev emits event LiquidityRemoved
   */
  function withdrawLiquidityNative(uint256 amount) external payable;

  // -------------------------------- REMOVE LIQUIDITY & BRIDGE TO ANOTHER NETWORK -------------------------------------
  /**
   * @notice Burns LP tokens and creates a bridge deposit in the amount of "burned LPTokens - withdrawal fee"
   *         For cases when no liquidity is available on the network the user provided liquidity in
   *
   * @param token the address of the ERC20 token in which liquidity was provided
   * @param amount the amount of the withdrawal
   * @param receiverAddress target address the bridged token should be sent to (in the target network)
   * @param targetChainId chain ID of the target network
   *
   * @dev emits event TokensDeposited after successful deposit
   */
  function withdrawLiquidityInAnotherNetwork(
    IERC20 token,
    uint256 amount,
    address receiverAddress,
    uint256 targetChainId
  ) external payable;

  // ---------------------------------------- GET LIQUIDITY WITHDRAWAL FEE ---------------------------------------------
  /**
   * @notice Returns the liquidity withdrawal fee amount for the given token
   *
   * @param token the address of the ERC20 token in which liquidity was provided
   * @param withdrawalAmount the amount of tokens to be withdrawn
   *
   */
  function getLiquidityWithdrawalFeeAmount(IERC20 token, uint256 withdrawalAmount) external view returns (uint256);

  // ###################################################################################################################
  // ***************************************** LIQUIDITY MINING POOLS **************************************************
  // ###################################################################################################################
  // ------------------------------------- STAKE LP TOKENS IN MINING POOLS ---------------------------------------------
  /**
   * @notice Adds LP tokens to the liquidity mining pool of the given token
   *
   * @param tokenAddress the address of the underlying token of the pool
   * @param amount the amount of LP tokens that should be staked
   *
   * @dev emits event StakeAdded
   */
  function stakeLpTokensInMiningPool(address tokenAddress, uint256 amount) external payable;

  // ----------------------------------- UNSTAKE LP TOKENS FROM MINING POOLS -------------------------------------------
  /**
   * @notice Withdraws staked LP tokens from the liquidity mining pool after harvesting available rewards, if any
   *
   * @param tokenAddress the address of the underlying token of the liquidity mining pool
   * @param amount the amount of LP tokens that should be unstaked
   *
   * @dev emits event RewardsHarvested, if rewards are available for harvesting
   * @dev emits event StakeAdded
   */
  function unstakeLpTokensFromMiningPool(address tokenAddress, uint256 amount) external payable;

  // -------------------------------- CHECK & HARVEST REWARDS FROM MINING POOLS ----------------------------------------
  /**
   * @notice Returns the amount of unharvested rewards for a specific address in the given liquidity mining pool
   *
   * @param tokenAddress the address of the underlying token of the reward pool
   * @param stakerAddress the address of the staker for which pending rewards should be returned
   * @return the unharvested reward amount
   */
  function pendingMiningPoolRewards(address tokenAddress, address stakerAddress) external view returns (uint256);

  /**
   * @notice Distributes unharvested staking rewards from the given liquidity mining pool
   *
   * @param tokenAddress the address of the underlying token of the pool
   * @param stakerAddress the address for which the unharvested rewards should be distributed
   *
   * @dev emits event RewardsHarvested
   */
  function harvestFromMiningPool(address tokenAddress, address stakerAddress) external payable;

  // ###################################################################################################################
  // ******************************************* BRIDGE CHEF FARMS *****************************************************
  // ###################################################################################################################
  // ----------------------------------------- STAKE LP TOKENS IN FARMS ------------------------------------------------

  /**
   * @notice Adds liquidity provider (LP) tokens to the given farm for the user to start earning BRIDGE tokens
   *
   * @param farmId the ID of the liquidity farm
   * @param amount LP token amount to be deposited
   *
   * @dev emits event DepositAdded after the deposit was successfully added
   */
  function stakeLpTokensInFarm(uint256 farmId, uint256 amount) external payable;

  // --------------------------------------- UNSTAKE LP TOKENS FROM FARMS ----------------------------------------------

  /**
   * @notice Withdraws liquidity provider (LP) tokens from the given farm
   *
   * @param farmId the ID of the liquidity farm
   * @param amount LP token amount to withdraw
   *
   * @dev emits event FundsWithdrawn after successful withdrawal
   */
  function unstakeLpTokensFromFarm(uint256 farmId, uint256 amount) external payable;

  // --------------------------------- CHECK & HARVEST BRIDGE REWARDS FROM FARMS ---------------------------------------

  /**
   * @notice Returns the amount of BRIDGE tokens that are ready for harvesting for the given user and farm
   *
   * @param farmId The index of the farm
   * @param user the address of the user to query the info for
   * @return returns the amount of bridge tokens that are ready for harvesting
   */
  function pendingFarmRewards(uint256 farmId, address user) external view returns (uint256);

  /**
   * @notice Harvests BRIDGE rewards and sends them to the caller of this function
   *
   * @param farmId the ID of the farm for which rewards should be harvested
   *
   * @dev emits event RewardsHarvested after the rewards have been transferred to the caller
   */
  function harvestFarmRewards(uint256 farmId) external payable;

  // ###################################################################################################################
  // ********************************************* REWARD POOLS ********************************************************
  // ###################################################################################################################
  // ----------------------------------- STAKE BRIDGE TOKENS IN REWARD POOLS -------------------------------------------
  /**
   * @notice Stakes BRIDGE tokens in the given staking pool
   *
   * NOTE: Withdrawals are subject to a fee {see unstakeBRIDGEFromRewardPools()}
   *
   * @param tokenAddress the address of the underlying token of the reward pool
   * @param amount the amount of bridge tokens that should be staked
   *
   * @dev emits event StakeAdded
   */
  function stakeBRIDGEInRewardPool(address tokenAddress, uint256 amount) external payable;

  // --------------------------------- UNSTAKE BRIDGE TOKENS FROM REWARD POOLS -----------------------------------------
  /**
   * @notice Unstakes BRIDGE tokens from the given reward pool
   *
   * Please note: Unstaking BRIDGE tokens is subject to a withdrawal fee.
   * To check the current fee rate, please refer to the following variables/functions
   *   1) check for custom withdrawal fee (if > 0 then this fee applies) : rewardPoolWithdrawalFees(tokenAddress)
   *   2) if no custom withdrawal fee applies, then default fee applies  : defaultRewardPoolWithdrawalFee()
   *
   * @param tokenAddress the address of the underlying token of the reward pool
   * @param amount the amount of bridge tokens that should be unstaked
   * @dev emits event StakeWithdrawn
   */
  function unstakeBRIDGEFromRewardPool(address tokenAddress, uint256 amount) external payable;

  // -------------------------------- CHECK & HARVEST REWARDS FROM REWARD POOLS ----------------------------------------
  /**
   * @notice Returns the amount of unharvested rewards for a specific address in the given reward pool
   *
   * @param tokenAddress the address of the underlying token of the reward pool
   * @param stakerAddress the address of the staker for which pending rewards should be returned
   * @return the unharvested reward amount
   */
  function pendingRewardPoolRewards(address tokenAddress, address stakerAddress) external view returns (uint256);

  /**
   * @notice Distributes unharvested staking rewards from the given reward pool
   *
   * @param tokenAddress the address of the underlying token of the pool
   * @param stakerAddress the address for which the unharvested rewards should be distributed
   * @dev emits event RewardsHarvested
   */
  function harvestFromRewardPool(address tokenAddress, address stakerAddress) external payable;

  // ------------------------------------ CHECK REWARD POOL WITHDRAWAL FEES --------------------------------------------
  /**
   * @notice Returns the specific withdrawal fee for the given token in parts per million (ppm)
   *
   * Example for ppm values:
   * 300,000  = 30%
   *  10,000 =   1%
   *
   * @return the withdrawal fee percentage in ppm
   */
  function rewardPoolWithdrawalFee(address tokenAddress) external view returns (uint256);

  // ###################################################################################################################
  // ******************************** LIST/DE-LIST YOUR ERC20/ERC721 TOKEN *********************************************
  // ****************** FOR PROJECTS THAT WANT TO USE OUR BRIDGE FOR THEIR TOKEN/COLLECTION ****************************
  // ###################################################################################################################
  // ------------------------------------------------- ERC20  ----------------------------------------------------------
  // For new ERC20 token listings on the bridge there are two cases:
  // 1) the token contracts have same addresses across all networks that should be connected
  // 2) the token contracts have different addresses across the networks that should be connected
  //
  // In case of 1), you need to add liquidity in each network (see section "MANAGE LIQUIDITY")
  // In case of 2), same as 1) plus you need to add token mappings in each network (see below)

  /**
   * @notice Adds a token contract mapping for an ERC20 token
   *
   * @param sourceNetworkTokenAddress the address of the token in another network that should be mapped to the target
   * @param targetTokenAddress the address of the target token in this network
   *
   * @dev only accepts new token mappings. To update an existing mapping, please contact support
   * @dev the token contract must have a public owner() function that returns the address of the owner
   * @dev if this is not possible, you can contact support to add your mapping
   * @dev emits event PeggedTokenMappingAdded
   */
  function addERC20TokenContractMapping(address sourceNetworkTokenAddress, address targetTokenAddress) external payable;

  /**
   * @notice Removes a token contract mapping for an ERC20 token
   *
   * @param sourceNetworkTokenAddress the address of the token in another network that should be mapped to the target
   *
   * @dev can only be called by the owner of the target token contract
   * @dev only accepts new token mappings. To update an existing mapping, please contact support
   * @dev the token contract must have a public owner() function that returns the address of the owner
   * @dev if this is not possible, you can contact support to add your mapping
   */
  function removeERC20TokenContractMapping(address sourceNetworkTokenAddress) external payable;

  /**
   * @notice Initial setup for a new ERC20 token. Creates all pools required by the bridge ecosystem.
   *         Can be called from a constructor of an ERC20 token to prepare token for bridging.
   *
   * @param createLiquidityPool creates a liquidity pool and a LP token, if true
   * @param createMiningPool creates a liquidity mining pool, if true
   * @param createRewardPool creates a reward pool, if true
   *
   * @dev emits events LiquidityPoolCreated, LiquidityMiningPoolCreated, RewardPoolCreated
   */
  function createPools(
    address tokenAddress,
    bool createLiquidityPool,
    bool createMiningPool,
    bool createRewardPool
  ) external payable;

  // ------------------------------------------------  ERC721  ---------------------------------------------------------
  // For new ERC721 collection listings on the bridge there are two cases:
  // 1) the collection contracts have same addresses across all networks that should be connected
  // 2) the collection contracts have different addresses across the networks that should be connected
  //
  // In case of 1), you need to add your collection to the whitelist (see below)
  // In case of 2), same as 1) plus you need to add collection mappings in each network (see below)

  /**
   * @notice Adds an ERC721 collection to the whitelist (effectively allowing bridge transactions for this collection)
   *
   * @param collectionAddress the address of the collection that should be added
   *
   * @dev can only be called by the owner of the collection
   * @dev the collection contract must have a public owner() function that returns the address of the owner
   * @dev if owner() function is not available, please contact support to whitelist your collection
   * @dev emits event AddedCollectionToWhitelist
   */
  function addERC721CollectionToWhitelist(address collectionAddress) external payable;

  /**
   * @notice Removes an ERC721 collection from the whitelist
   *         (effectively disabling bridge transactions for this collection)
   *
   * @param collectionAddress the address of the collection that should be removed
   *
   * @dev can only be called by the owner of the collection
   * @dev the collection contract must have a public owner() function that returns the address of the owner
   * @dev if owner() function is not available, please contact support to de-whitelist your collection
   * @dev emits event RemovedCollectionFromWhitelist
   */
  function removeERC721CollectionFromWhitelist(address collectionAddress) external payable;

  /**
   * @notice Adds a new collection address mapping (to connect collections with different addresses across networks)
   *
   * @param sourceNetworkCollectionAddress the address of a collection in another network that should be mapped to the target
   * @param targetCollectionAddress the address of the target collection in this network
   *
   * @dev can only be called by the owner of the collection
   * @dev only accepts new collection mappings. To update an existing mapping, please contact support
   * @dev the collection contract must have a public owner() function that returns the address of the owner
   * @dev if owner() function is not available, please contact support
   * @dev emits event PeggedCollectionMappingAdded
   */
  function addERC721CollectionAddressMapping(address sourceNetworkCollectionAddress, address targetCollectionAddress)
    external
    payable;

  /**
   * @notice Removes a collection address mapping from sourceNetworkCollectionAddress to targetCollectionAddress
   *
   * @param sourceNetworkCollectionAddress the address of a collection in another network that is mapped to the target
   *
   * @dev can only be called by the owner of the target collection (=the mapped-to collection in this network)
   * @dev the target collection contract must have a public owner() function that returns the address of the owner
   * @dev if owner() function is not available, please contact support
   */
  function removeERC721CollectionAddressMapping(address sourceNetworkCollectionAddress) external payable;

  // ###################################################################################################################
  // ****************************************** AUXILIARY FUNCTIONS ****************************************************
  // ###################################################################################################################
  /**
   * @notice Returns the wrapped native token contract address that is used in this network
   */
  function wrappedNative() external view returns (address);

  /**
   * @notice Returns the address of the LP token for a given token address
   *
   * @dev returns zero address if LP token does not exist
   * @param tokenAddress the address of token for which the LP token should be returned
   */
  function getLPToken(address tokenAddress) external view returns (address);

  /**
   * @notice returns the ID of the network this contract is deployed in
   */
  function getChainID() external view returns (uint256);
}
