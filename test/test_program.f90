program test_git_version
  use git_version
  implicit none

  print*, "Version: ", get_git_version()
  print*, "Latest commit: ", get_git_hash()
end program test_git_version
