@Grab('org.codehaus.groovy.modules.http-builder:http-builder:0.7.2')
@Grab('org.apache.commons:commons-compress:1.11')
@Grab('org.jfrog.artifactory.client:artifactory-java-client-services:1.2.2')
@GrabExclude('org.codehaus.groovy:groovy-xml:2.3.2')

import org.jfrog.artifactory.client.*

import org.artifactory.fs.ItemInfo
import org.artifactory.fs.FileLayoutInfo
import org.artifactory.repo.RepoPath
import org.artifactory.repo.RepoPathFactory
import groovyx.net.http.RESTClient

import org.apache.commons.compress.archivers.zip.ZipFile
import org.apache.commons.compress.archivers.zip.ZipArchiveEntry
import org.apache.commons.compress.archivers.zip.ZipArchiveInputStream

import org.artifactory.resource.ResourceStreamHandle

executions {

  /**
  * An execution definition.
  * The first value is a unique name for the execution.
  *
  * Context variables:
  * status (int) - a response status code. Defaults to -1 (unset). Not applicable for an async execution.
  * message (java.lang.String) - a text message to return in the response body, replacing the response content.
  *                              Defaults to null. Not applicable for an async execution.
  *
  * Plugin info annotation parameters:
  *  version (java.lang.String) - Closure version. Optional.
  *  description (java.lang.String) - Closure description. Optional.
  *  httpMethod (java.lang.String, values are GET|PUT|DELETE|POST) - HTTP method this closure is going
  *    to be invoked with. Optional (defaults to POST).
  *  params (java.util.Map<java.lang.String, java.lang.String>) - Closure default parameters. Optional.
  *  users (java.util.Set<java.lang.String>) - Users permitted to query this plugin for information or invoke it.
  *  groups (java.util.Set<java.lang.String>) - Groups permitted to query this plugin for information or invoke it.
  *
  * Closure parameters:
  *  params (java.util.Map) - An execution takes a read-only key-value map that corresponds to the REST request
  *    parameter 'params'. Each entry in the map contains an array of values. This is the default closure parameter,
  *    and so if not named it will be "it" in groovy.
  *  ResourceStreamHandle body - Enables you to access the full input stream of the request body.
  *    This will be considered only if the type ResourceStreamHandle is declared in the closure.
  */

  zipUpload(groups: ["readers"], httpMethod: 'PUT') { params, ResourceStreamHandle body ->
    // The repository to add into
    String repo = params['repo'][0]

    // File path prefix
    String path = params['path'][0]

    // Create a temporary version of the zip file locally
    File tempFile = File.createTempFile("zip_archive", ".zip")

    // Output stream to the file
    BufferedOutputStream zipOutput = new BufferedOutputStream(new FileOutputStream(tempFile))

    // Input stream from the resource stream handleRequest
    BufferedInputStream bodyInputStream  = new BufferedInputStream(body.getInputStream())


    final byte[] buf = new byte[4096] // Buffer for file reading
    int bytesRead                     // Number of bytes read in a reading

    // Read all of body until done
    while ((bytesRead = bodyInputStream.read(buf)) != -1) {
      zipOutput.write(buf, 0, bytesRead)
    }

    // Close file output stream and handler input stream
    bodyInputStream.close()
    zipOutput.close()

    // Handler for our new zip file
    ZipFile zipFile = new ZipFile(tempFile)

    // Iterate through all of the zip entries
    Enumeration<ZipArchiveEntry> zipEntriesEnum = zipFile.getEntries()
    Iterator zipEntries = zipEntriesEnum.iterator()

    // Client for communicating with Artifactory
    Artifactory artifactory =
    ArtifactoryClient.create("http://localhost:8081/artifactory",
    security.getCurrentUsername(),
    security.getEncryptedPassword());

    // Set of directories
    Set<ZipArchiveEntry> folderSet = new HashSet()

    while(zipEntries.hasNext()) {
      ZipArchiveEntry zipEntry = (ZipArchiveEntry) zipEntries.next()

      // Get permissions on entry
      String mode = Integer.toOctalString(zipEntry.getUnixMode() & 07777)

      // Only upload files
      if(!zipEntry.isDirectory()) {
        // Temporary file from zip archive
        File tempZipEntryFile = File.createTempFile("zip_entry", null)

        // Input stream from zip file
        BufferedInputStream zipEntryStream = new BufferedInputStream(zipFile.getInputStream(zipEntry))

        // Output stream to tem zip file
        FileOutputStream tempZipEntryFileOut = new FileOutputStream(tempZipEntryFile)

        while ((bytesRead = zipEntryStream.read(buf)) != -1) {
          tempZipEntryFileOut.write(buf, 0, bytesRead)
        }

        // Cleanup
        zipEntryStream.close()
        tempZipEntryFileOut.close()

        // Upload file
        artifactory.repository(repo).upload(path + '/' + zipEntry.getName(), tempZipEntryFile)
        .withProperty("mode", mode)
        .doUpload()

        // Delete temp file
        tempZipEntryFile.delete()
      }
      else {
        folderSet.add(zipEntry)
      }
    }

    // Finish up with permissions on the folders
    Iterator<ZipArchiveEntry> folderIterator = folderSet.iterator()

    while(folderIterator.hasNext()) {
      ZipArchiveEntry zipEntry = (ZipArchiveEntry) folderIterator.next()

      // Get permissions on entry
      String mode = Integer.toOctalString(zipEntry.getUnixMode() & 07777)

      RepoPath folderPath = RepoPathFactory.create(repo, path + '/' + zipEntry.getName())

      repositories.setProperty(folderPath, 'mode', mode)
    }

    tempFile.delete()
  }


  /**
  ZipArchiveInputStream zipInputStream = new ZipArchiveInputStream(zipInputStream)

  ZipArchiveEntry nextZipEntry

  // Get entries until Downloaded
  while((nextZipEntry = zipInputStream.getNextZipEntry()) != null) {
  boolean isDirectory = nextZipEntry.isDirectory()
  String filePermissions = Integer.toOctalString(nextZipEntry.getUnixMode() & 07777)

  log.warn("First: " + nextZipEntry.getUnixMode())
  log.warn("Second: " + Integer.toOctalString(nextZipEntry.getUnixMode()))
  log.warn("Third: " + Integer.toOctalString(nextZipEntry.getUnixMode() & 07777))

  log.warn('Name: ' + nextZipEntry.getName() + ' Perms: ' + filePermissions + ' Is Dir: ' + isDirectory)
}
}
*/
}
