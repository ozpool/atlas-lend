export interface NetworkConfig {
  name: string;
  chainId: number;
  rpcUrl: string;
  blockConfirmations: number;
}

export const networkConfig: Record<number, NetworkConfig> = {
  31337: {
    name: "localhost",
    chainId: 31337,
    rpcUrl: "http://127.0.0.1:8545",
    blockConfirmations: 1
  },
  11155111: {
    name: "sepolia",
    chainId: 11155111,
    rpcUrl: process.env.SEPOLIA_RPC_URL || "",
    blockConfirmations: 3
  }
};
