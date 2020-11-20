export const mockPipelineResponse = {
  'data': {
    'project': {
      __typename: 'Project',
      'pipeline': {
        __typename: 'Pipeline',
        'iid': '22',
        'stages': {
          __typename: 'CiStageConnection',
          'nodes': [
            {
              __typename: 'CiGroup',
              'name': 'build',
              'status': {
                'action': null
              },
              'groups': {
                'nodes': [
                  {
                    'id': 'build_a_nlfjkdnlvskfnksvjknlfdjvlvnjdkjdf_nvjkenjkrlngjeknjkl',
                    'size': 1,
                    'status': {
                      'label': 'passed',
                      'group': 'success',
                      'icon': 'status_success'
                    },
                    'jobs': {
                      'nodes': [
                        {
                          'name': 'build_a_nlfjkdnlvskfnksvjknlfdjvlvnjdkjdf_nvjkenjkrlngjeknjkl',
                          'scheduledAt': null,
                          'status': {
                            'icon': 'status_success',
                            'tooltip': 'passed',
                            'hasDetails': true,
                            'detailsPath': '/root/abcd-dag/-/jobs/1482',
                            'group': 'success',
                            'action': {
                              'buttonTitle': 'Retry this job',
                              'icon': 'retry',
                              'path': '/root/abcd-dag/-/jobs/1482/retry',
                              'title': 'Retry'
                            }
                          },
                          'needs': {
                            'nodes': []
                          }
                        }
                      ]
                    }
                  },
                  {
                    'id': 'build_b',
                    'size': 1,
                    'status': {
                      'label': 'passed',
                      'group': 'success',
                      'icon': 'status_success'
                    },
                    'jobs': {
                      'nodes': [
                        {
                          'name': 'build_b',
                          'scheduledAt': null,
                          'status': {
                            'icon': 'status_success',
                            'tooltip': 'passed',
                            'hasDetails': true,
                            'detailsPath': '/root/abcd-dag/-/jobs/1515',
                            'group': 'success',
                            'action': {
                              'buttonTitle': 'Retry this job',
                              'icon': 'retry',
                              'path': '/root/abcd-dag/-/jobs/1515/retry',
                              'title': 'Retry'
                            }
                          },
                          'needs': {
                            'nodes': []
                          }
                        }
                      ]
                    }
                  },
                  {
                    'id': 'build_c',
                    'size': 1,
                    'status': {
                      'label': 'passed',
                      'group': 'success',
                      'icon': 'status_success'
                    },
                    'jobs': {
                      'nodes': [
                        {
                          'name': 'build_c',
                          'scheduledAt': null,
                          'status': {
                            'icon': 'status_success',
                            'tooltip': 'passed',
                            'hasDetails': true,
                            'detailsPath': '/root/abcd-dag/-/jobs/1484',
                            'group': 'success',
                            'action': {
                              'buttonTitle': 'Retry this job',
                              'icon': 'retry',
                              'path': '/root/abcd-dag/-/jobs/1484/retry',
                              'title': 'Retry'
                            }
                          },
                          'needs': {
                            'nodes': []
                          }
                        }
                      ]
                    }
                  },
                  {
                    'id': 'build_d',
                    'size': 3,
                    'status': {
                      'label': 'passed',
                      'group': 'success',
                      'icon': 'status_success'
                    },
                    'jobs': {
                      'nodes': [
                        {
                          'name': 'build_d 1/3',
                          'scheduledAt': null,
                          'status': {
                            'icon': 'status_success',
                            'tooltip': 'passed',
                            'hasDetails': true,
                            'detailsPath': '/root/abcd-dag/-/jobs/1485',
                            'group': 'success',
                            'action': {
                              'buttonTitle': 'Retry this job',
                              'icon': 'retry',
                              'path': '/root/abcd-dag/-/jobs/1485/retry',
                              'title': 'Retry'
                            }
                          },
                          'needs': {
                            'nodes': []
                          }
                        },
                        {
                          'name': 'build_d 2/3',
                          'scheduledAt': null,
                          'status': {
                            'icon': 'status_success',
                            'tooltip': 'passed',
                            'hasDetails': true,
                            'detailsPath': '/root/abcd-dag/-/jobs/1486',
                            'group': 'success',
                            'action': {
                              'buttonTitle': 'Retry this job',
                              'icon': 'retry',
                              'path': '/root/abcd-dag/-/jobs/1486/retry',
                              'title': 'Retry'
                            }
                          },
                          'needs': {
                            'nodes': []
                          }
                        },
                        {
                          'name': 'build_d 3/3',
                          'scheduledAt': null,
                          'status': {
                            'icon': 'status_success',
                            'tooltip': 'passed',
                            'hasDetails': true,
                            'detailsPath': '/root/abcd-dag/-/jobs/1487',
                            'group': 'success',
                            'action': {
                              'buttonTitle': 'Retry this job',
                              'icon': 'retry',
                              'path': '/root/abcd-dag/-/jobs/1487/retry',
                              'title': 'Retry'
                            }
                          },
                          'needs': {
                            'nodes': []
                          }
                        }
                      ]
                    }
                  }
                ]
              }
            },
            {
              __typename: 'CiGroup',
              'name': 'test',
              'status': {
                'action': null
              },
              'groups': {
                'nodes': [
                  {
                    'id': 'test_a',
                    'size': 1,
                    'status': {
                      'label': 'passed',
                      'group': 'success',
                      'icon': 'status_success'
                    },
                    'jobs': {
                      'nodes': [
                        {
                          'name': 'test_a',
                          'scheduledAt': null,
                          'status': {
                            'icon': 'status_success',
                            'tooltip': 'passed',
                            'hasDetails': true,
                            'detailsPath': '/root/abcd-dag/-/jobs/1514',
                            'group': 'success',
                            'action': {
                              'buttonTitle': 'Retry this job',
                              'icon': 'retry',
                              'path': '/root/abcd-dag/-/jobs/1514/retry',
                              'title': 'Retry'
                            }
                          },
                          'needs': {
                            'nodes': [
                              {
                                'name': 'build_c'
                              },
                              {
                                'name': 'build_b'
                              },
                              {
                                'name': 'build_a_nlfjkdnlvskfnksvjknlfdjvlvnjdkjdf_nvjkenjkrlngjeknjkl'
                              }
                            ]
                          }
                        }
                      ]
                    }
                  },
                  {
                    'id': 'test_b',
                    'size': 2,
                    'status': {
                      'label': 'passed',
                      'group': 'success',
                      'icon': 'status_success'
                    },
                    'jobs': {
                      'nodes': [
                        {
                          'name': 'test_b 1/2',
                          'scheduledAt': null,
                          'status': {
                            'icon': 'status_success',
                            'tooltip': 'passed',
                            'hasDetails': true,
                            'detailsPath': '/root/abcd-dag/-/jobs/1489',
                            'group': 'success',
                            'action': {
                              'buttonTitle': 'Retry this job',
                              'icon': 'retry',
                              'path': '/root/abcd-dag/-/jobs/1489/retry',
                              'title': 'Retry'
                            }
                          },
                          'needs': {
                            'nodes': [
                              {
                                'name': 'build_d 3/3'
                              },
                              {
                                'name': 'build_d 2/3'
                              },
                              {
                                'name': 'build_d 1/3'
                              },
                              {
                                'name': 'build_b'
                              },
                              {
                                'name': 'build_a_nlfjkdnlvskfnksvjknlfdjvlvnjdkjdf_nvjkenjkrlngjeknjkl'
                              }
                            ]
                          }
                        },
                        {
                          'name': 'test_b 2/2',
                          'scheduledAt': null,
                          'status': {
                            'icon': 'status_success',
                            'tooltip': 'passed',
                            'hasDetails': true,
                            'detailsPath': '/root/abcd-dag/-/jobs/1490',
                            'group': 'success',
                            'action': {
                              'buttonTitle': 'Retry this job',
                              'icon': 'retry',
                              'path': '/root/abcd-dag/-/jobs/1490/retry',
                              'title': 'Retry'
                            }
                          },
                          'needs': {
                            'nodes': [
                              {
                                'name': 'build_d 3/3'
                              },
                              {
                                'name': 'build_d 2/3'
                              },
                              {
                                'name': 'build_d 1/3'
                              },
                              {
                                'name': 'build_b'
                              },
                              {
                                'name': 'build_a_nlfjkdnlvskfnksvjknlfdjvlvnjdkjdf_nvjkenjkrlngjeknjkl'
                              }
                            ]
                          }
                        }
                      ]
                    }
                  },
                  {
                    'id': 'test_c',
                    'size': 1,
                    'status': {
                      'label': null,
                      'group': 'success',
                      'icon': 'status_success'
                    },
                    'jobs': {
                      'nodes': [
                        {
                          'name': 'test_c',
                          'scheduledAt': null,
                          'status': {
                            'icon': 'status_success',
                            'tooltip': null,
                            'hasDetails': true,
                            'detailsPath': '/root/kinder-pipe/-/pipelines/154',
                            'group': 'success',
                            'action': null
                          },
                          'needs': {
                            'nodes': [
                              {
                                'name': 'build_c'
                              },
                              {
                                'name': 'build_b'
                              },
                              {
                                'name': 'build_a_nlfjkdnlvskfnksvjknlfdjvlvnjdkjdf_nvjkenjkrlngjeknjkl'
                              }
                            ]
                          }
                        }
                      ]
                    }
                  },
                  {
                    'id': 'test_d',
                    'size': 1,
                    'status': {
                      'label': null,
                      'group': 'success',
                      'icon': 'status_success'
                    },
                    'jobs': {
                      'nodes': [
                        {
                          'name': 'test_d',
                          'scheduledAt': null,
                          'status': {
                            'icon': 'status_success',
                            'tooltip': null,
                            'hasDetails': true,
                            'detailsPath': '/root/abcd-dag/-/pipelines/153',
                            'group': 'success',
                            'action': null
                          },
                          'needs': {
                            'nodes': [
                              {
                                'name': 'build_b'
                              }
                            ]
                          }
                        }
                      ]
                    }
                  }
                ]
              }
            }
          ]
        }
      }
    }
  }
}
