package scorex.network.peer

import java.net.InetSocketAddress

//todo: add optional nonce
@SerialVersionUID(-8490103514095092419L)
case class PeerInfo(lastSeen: Long, nonce: Option[Long] = None, nodeName: Option[String] = None)

trait PeerDatabase {
  def addOrUpdateKnownPeer(peer: InetSocketAddress, peerInfo: PeerInfo): Unit

  def knownPeers(forSelf: Boolean): Map[InetSocketAddress, PeerInfo]

  def blacklistPeer(peer: InetSocketAddress): Unit

  def removeFromBlacklist(peer: InetSocketAddress): Unit

  def blacklistedPeers(): Seq[String]

  def isBlacklisted(address: InetSocketAddress): Boolean
}

