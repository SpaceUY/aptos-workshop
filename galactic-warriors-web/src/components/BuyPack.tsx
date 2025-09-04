"use client";

import React, { useState, useEffect, useCallback } from "react";
import { useWalletContext } from "../contexts/WalletContext";
import { Package, Coins, AlertCircle, CheckCircle } from "lucide-react";
import { motion } from "framer-motion";
import { GameStats } from "../types";
import {
  prepareBuyPackTransaction,
  getTotalPacksSold,
} from "../actions/aptosActions";
import {
  AccountAuthenticator,
  Deserializer,
  MultiAgentTransaction,
} from "@aptos-labs/ts-sdk";

const BuyPack: React.FC = () => {
  const { account, connected, signTransaction, client } = useWalletContext();
  const [gameStats, setGameStats] = useState<GameStats>({
    total_packs_sold: 0,
    user_pack_count: 0,
  });
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState<{
    type: "success" | "error";
    text: string;
  } | null>(null);

  const loadGameStats = useCallback(async () => {
    if (!connected || !account) return;

    try {
      const totalPacksSold = await getTotalPacksSold();
      setGameStats({
        total_packs_sold: totalPacksSold,
        user_pack_count: 0, // This will be updated by the contract
      });
    } catch (error) {
      console.error("Error loading game stats:", error);
    }
  }, [connected, account]);

  useEffect(() => {
    loadGameStats();
  }, [connected, account, loadGameStats]);

  const handleBuyPack = async () => {
    if (!connected || !account) {
      setMessage({ type: "error", text: "Please connect your wallet first" });
      return;
    }

    setLoading(true);
    setMessage(null);

    try {
      const transactionPayload = await prepareBuyPackTransaction(
        account.address.toString()
      );

      const deserializer = new Deserializer(
        Uint8Array.from(transactionPayload.transactionBytes)
      );
      const txn = MultiAgentTransaction.deserialize(deserializer);

      const deserializer2 = new Deserializer(
        Uint8Array.from(transactionPayload.creatorAuthBytes)
      );
      const creatorAuth = AccountAuthenticator.deserialize(deserializer2);

      const signResult = await signTransaction({
        transactionOrPayload: txn,
      });
      const senderAuth = signResult.authenticator;

      const committedTransaction = await client.transaction.submit.multiAgent({
        transaction: txn,
        senderAuthenticator: senderAuth,
        additionalSignersAuthenticators: [creatorAuth],
      });

      const executedTransaction = await client.waitForTransaction({
        transactionHash: committedTransaction.hash,
      });
      setMessage({
        type: "success",
        text: `Pack purchased successfully! Transaction: ${executedTransaction.hash.slice(
          0,
          8
        )}...`,
      });

      loadGameStats();
    } catch (error) {
      console.error("❌ Error purchasing pack:", error);
      setMessage({
        type: "error",
        text: "Error purchasing pack. Please try again.",
      });
    } finally {
      setLoading(false);
    }
  };

  if (!connected) {
    return (
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="galactic-card p-12 text-center"
      >
        <AlertCircle size={64} className="text-yellow-400 mx-auto mb-6" />
        <h2 className="text-2xl font-bold text-white mb-4">
          Wallet Not Connected
        </h2>
        <p className="text-white/80 text-lg">
          You need to connect your wallet to buy packs
        </p>
      </motion.div>
    );
  }

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="max-w-4xl mx-auto"
    >
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.3 }}
        className="galactic-card p-8 text-center"
      >
        <div className="w-32 h-32 bg-gradient-to-r from-galactic-purple to-galactic-pink rounded-full flex items-center justify-center mx-auto mb-6 overflow-hidden shadow-2xl shadow-galactic-purple/30 hover:shadow-2xl hover:shadow-galactic-pink/40 transition-all duration-300 hover:scale-105">
          <img
            src="/pack.png"
            alt="Galactic Pack"
            className="w-20 h-20 object-contain drop-shadow-lg"
          />
        </div>

        <h2 className="text-3xl font-bold text-white mb-4">
          Buy Galactic Pack
        </h2>
        <p className="text-white/80 text-lg mb-6 max-w-2xl mx-auto">
          Each pack contains 3 characters: one Alien, one Predator, and one
          Yoda, each with random rarity. Unlock legendary characters and build
          your collection!
        </p>

        <div className="flex items-center justify-center gap-3 mb-8 text-white/80">
          <Coins size={20} className="text-yellow-400" />
          <span className="text-lg">
            <span className="font-semibold text-white">
              {gameStats.total_packs_sold.toLocaleString()}
            </span>{" "}
            Total Packs Sold
          </span>
        </div>

        <div className="space-y-4">
          <button
            onClick={handleBuyPack}
            disabled={loading}
            className={`galactic-button text-lg px-12 py-4 ${
              loading ? "opacity-50 cursor-not-allowed" : ""
            }`}
          >
            {loading ? (
              <div className="flex items-center gap-2">
                <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                Processing...
              </div>
            ) : (
              <div className="flex items-center gap-2">
                <Package size={24} />
                Buy Pack for 0.1 APT
              </div>
            )}
          </button>

          <div className="h-px bg-gradient-to-r from-transparent via-white/20 to-transparent my-4"></div>

          <a
            href={`https://cloud.hasura.io/public/graphiql?endpoint=${encodeURIComponent(
              "https://api.testnet.aptoslabs.com/v1/graphql"
            )}&query=${encodeURIComponent(`query MyQuery {
  current_token_datas_v2(
    where: {collection_id: {_eq: "${process.env.NEXT_PUBLIC_PACKS_COLLECTION_ADDRESS}"}}
  ) {
    token_properties
    token_name
    token_data_id
  }
}`)}`}
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center gap-2 px-6 py-3 bg-gradient-to-r from-blue-600 to-cyan-600 hover:from-blue-700 hover:to-cyan-700 text-white font-medium rounded-lg transition-all duration-300 hover:scale-105 hover:shadow-lg hover:shadow-blue-500/25"
          >
            <Package size={20} />
            Check Packs Information
          </a>

          {message && (
            <motion.div
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              className={`flex items-center justify-center gap-2 p-4 rounded-lg ${
                message.type === "success"
                  ? "bg-green-500/20 text-green-400 border border-green-500/30"
                  : "bg-red-500/20 text-red-400 border border-red-500/30"
              }`}
            >
              {message.type === "success" ? (
                <CheckCircle size={20} />
              ) : (
                <AlertCircle size={20} />
              )}
              {message.text}
            </motion.div>
          )}
        </div>
      </motion.div>

      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.4 }}
        className="galactic-card p-8 mt-8"
      >
        <div className="text-center mb-10">
          <h3 className="text-3xl font-bold text-white mb-4">
            ⚡ Rarity System
          </h3>
          <p className="text-white/60 text-lg max-w-3xl mx-auto">
            Discover the power levels of your galactic warriors. Each character
            gets a random rarity with unique drop rates that make every pack
            opening exciting!
          </p>
        </div>

        <div className="grid md:grid-cols-3 lg:grid-cols-6 gap-6">
          {[
            { name: "Common", color: "gray", emoji: "⚪", chance: 30 },
            { name: "Uncommon", color: "green", emoji: "🟢", chance: 25 },
            { name: "Rare", color: "blue", emoji: "🔵", chance: 20 },
            { name: "Epic", color: "purple", emoji: "🟣", chance: 12 },
            { name: "Legendary", color: "orange", emoji: "🟠", chance: 8 },
            { name: "Mythic", color: "red", emoji: "🔴", chance: 5 },
          ].map((rarity) => (
            <div key={rarity.name} className="group cursor-pointer">
              <div
                className={`relative overflow-hidden rounded-2xl bg-gradient-to-br from-${rarity.color}-500 via-${rarity.color}-400 to-${rarity.color}-300 p-4 text-center transform transition-all duration-300 hover:scale-105 hover:shadow-2xl hover:shadow-${rarity.color}-500/25`}
              >
                <div
                  className={`absolute inset-0 bg-gradient-to-br from-${rarity.color}-600/20 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300`}
                ></div>
                <div className="relative z-10">
                  <div className="w-12 h-12 bg-white/20 rounded-full flex items-center justify-center mx-auto mb-3 backdrop-blur-sm">
                    <span className="text-xl">{rarity.emoji}</span>
                  </div>
                  <h4 className="text-base font-bold text-white mb-2">
                    {rarity.name}
                  </h4>
                  <div className="bg-white/20 rounded-full px-3 py-1 backdrop-blur-sm">
                    <span className="text-white font-semibold text-sm">
                      {rarity.chance}%
                    </span>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>

        <div className="mt-8 text-center">
          <div className="inline-flex items-center gap-3 bg-white/10 rounded-full px-6 py-3 backdrop-blur-sm">
            <span className="text-yellow-400 text-lg">💎</span>
            <span className="text-white/80 text-xs">
              Higher rarities have special abilities and unique traits!
            </span>
          </div>
        </div>
      </motion.div>
    </motion.div>
  );
};

export default BuyPack;
